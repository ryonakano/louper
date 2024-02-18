# Contribution Guideline

Thank you for getting interested in contribution to this project! We really appreciate it. 😊

## Table of Contents

- [Submit Bug Reports or Feature Requests](#submit-bug-reports-or-feature-requests)
- [Translate the Project](#translate-the-project)
- [Propose Code Changes](#propose-code-changes)
    - [Coding Style](#coding-style)
- [Manage the Project](#manage-the-project)
    - [Release Flow](#release-flow)

## Submit Bug Reports or Feature Requests

- [Search for existing issues](https://github.com/ryonakano/louper/issues) to check if it's a known issue.
- If it's not reported yet, [create a new issue](https://github.com/ryonakano/louper/issues/new).

> [!TIP]
> If you are not used to do, [this section](https://docs.elementary.io/contributor-guide/feedback/reporting-issues#creating-a-new-issue-report) is for you.

## Translate the Project

We accept translations through Weblate:

- [louper-app](https://hosted.weblate.org/projects/rosp/louper-app/): Texts in the app itself
- [louper-metainfo](https://hosted.weblate.org/projects/rosp/louper-metainfo/): Texts in the desktop entry and the software center

Alternatively, you can fork this repository, edit the `*.po` files directly, and submit changes through pull requests.

> [!NOTE]
> Strings in the translation files are updated automatically if they're changed in the source code.
>
> Things to happen when strings are changed in the source code:
>
> - GitHub Actions ([gettext-flatpak](https://github.com/elementary/actions/tree/main/gettext-flatpak)) updates the `*.pot` file and commits it to the repository
> - Weblate Addon ([Update PO files to match POT (msgmerge)](https://docs.weblate.org/en/latest/admin/addons.html#addon-weblate-gettext-msgmerge)) detects the modification of `*.pot` file, updates `*.po` files accordingly, and commits them to the repository

## Propose Code Changes

We accept changes to the source code through pull requests―even a small typo fix is welcome.

> [!TIP]
> Again, [the guideline by elementary](https://docs.elementary.io/contributor-guide/development/prepare-code-for-review) would be helpful here too.

### Coding Style

We follow [the coding style of elementary OS](https://docs.elementary.io/develop/writing-apps/code-style) and [its Human Interface Guidelines](https://docs.elementary.io/hig/). Try to respect them.

## Manage the Project

### Release Flow
#### Works in Project Repository

- Repository URL: https://github.com/ryonakano/louper
- Decide the version number of the release
    - Versioning should follow [Semantic Versioning](https://semver.org/)
- Create a new branch named `release-X.Y.Z` from the latest `origin/main` (`X.Y.Z` is the version number)
- See changes since the previous release: `git diff $(git describe --tags --abbrev=0)..release-X.Y.Z`
- Perform changes
    - Write a release note in `data/louper.metainfo.xml.in`
        - Refer to [the Metainfo guidelines by Flathub](https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines/#release)
        - Credits contributors with their GitHub username
            - Translation contributors are excluded because some don't have a GitHub account. Just writing `Update translations` is fine
    - Bump `version` in `meson.build`
    - Update screenshots if there are visual changes between releases
- Create a pull request with the above changes
- Merge it once the build succeeded
- [Create a new release on GitHub](https://github.com/ryonakano/louper/releases/new)
    - Create a new tag named `X.Y.Z`
    - Release title: `<Project Name> X.Y.Z Released`
    - It's fine to reuse the release note in the metainfo file as the release description. Just convert XML to Markdown
    - Publish it when completed

#### Works in AppCenter Review repository

- Repository URL: https://github.com/elementary/appcenter-reviews
- Fork the repository if you don't have write access to it
- Create a new branch named `com.github.ryonakano.louper-X.Y.Z`
- Perform changes
    - Change `commit` and `version` in the `applications/com.github.ryonakano.louper.json`
        - `commit` should be the release commit just we published on the project repository
        - `version` for the relase version
- Create a pull request with the above changes
- Await for review approval and merge
- The new release should be available on AppCenter after some time
