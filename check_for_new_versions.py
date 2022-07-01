"""Check for new Git versions"""
import json
import sys
import logging
import subprocess

import requests

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

stdout_handler = logging.StreamHandler()
stdout_handler.setLevel(logging.DEBUG)
stdout_format = logging.Formatter("%(levelname)s %(message)s")
stdout_handler.setFormatter(stdout_format)
logger.addHandler(stdout_handler)

# TODO remove max tags after testing
MAX_TAGS = 2


def get_tags(organisation: str, repository: str) -> dict:
    """Get the github tags from a repo"""

    # This will only get the last 30 tags
    url = f"https://api.github.com/repos/{organisation}/{repository}/tags"
    logger.debug("Getting tags from %s", url)

    req = requests.get(url)

    if req.status_code != 200:
        logger.critical(
            "Unable to fetch git tags HTTP %s %s", req.status_code, req.text
        )
        sys.exit(1)

    try:
        tags = json.loads(req.text)
    except ValueError as exception_msg:
        logger.critical("Unable to parse JSON, %e", exception_msg)
        sys.exit(2)

    logger.info("Found %s tags for %s/%s", len(tags), organisation, repository)

    tag_list = []
    for tag in tags:
        tag_list.append(tag["name"])

    return tag_list


def is_prerelease(tag: dict) -> bool:
    """Does the release name contain -rc"""

    if "-rc" in tag:
        logger.debug("%s is pre-release", tag)
        return True

    logger.debug("%s is release", tag)
    return False


def trigger_workflow(tag: str, prerelease: bool) -> None:
    """Launch the github CLI as a subprocess and trigger a workflow run"""

    # pre-release tag needs to be lower
    prerelease = str(prerelease).lower()

    command = [
        "gh",
        "workflow",
        "run",
        "auto_build.yml",
        "-f",
        f"tag={tag}",
        "-f",
        f"prerelease={prerelease}",
    ]

    logger.debug("Running command %s", command)
    with subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    ) as proc:
        _, err = proc.communicate()

        if proc.returncode != 0:
            logger.critical("Error running GitHub CLI: %s", err.decode("utf-8"))
            sys.exit(3)

    logger.info("Successfully triggered workflow for GitHub %s", tag)


def main() -> None:
    """Get all tags, compare, and trigger missing tag runs"""

    git_tags = get_tags(organisation="git", repository="git")
    macadmins_tags = get_tags(
        organisation="rorymurdock", repository="git"
    )

    # Loop through all the tags and find missing ones
    for git_tag in git_tags[:MAX_TAGS]:
        if git_tag in macadmins_tags:
            # Tag found, take no action
            logger.info("Git tag %s found in MacAdmins repo, skipping", git_tag)
            continue

        # Tag not found, trigger a Github workflow run
        logger.info("Git tag %s not found in MacAdmins repo", git_tag)

        if is_prerelease(git_tag):
            logger.info("Triggering pre-release build %s", git_tag)
            trigger_workflow(tag=git_tag, prerelease=True)
        else:
            logger.info("Triggering release build %s", git_tag)
            trigger_workflow(tag=git_tag, prerelease=False)


if __name__ == "__main__":
    main()
