.. _ci:

Continuous Integration
======================

Bash-it uses `GitHub Actions <https://github.com/Bash-it/bash-it/actions>`_ for Continuous Integration (CI).
The CI configuration is defined in ``.github/workflows/ci.yml``.

Workflows
---------

The CI workflow is triggered on every ``push`` and ``pull_request`` event.

Updating CI actions
-------------------

Updating the CI workflow action should be done by pinning action to their sha commit and using a 10 days cooldown.
This can be done with `pinact <https://github.com/suzuki-shunsuke/pinact>`_:

::

    pinact run --update --min-age 10

Jobs
----

The CI process consists of the following jobs:

Bats Test
^^^^^^^^^

This job runs the unit tests using the `Bats unit test framework <https://github.com/bats-core/bats-core>`_.
The tests are executed on the following operating systems:

* Ubuntu 24.04
* macOS 14

Build Docs
^^^^^^^^^^

This job ensures that the documentation can be built successfully using `Sphinx <https://www.sphinx-doc.org/>`_.
It runs on ``ubuntu-latest`` and uses Python 3.12.

Lint
^^^^

This job runs several linting tools to ensure code quality:

* `shfmt <https://github.com/mvdan/sh>`_: Checks shell script formatting.
* `shellcheck <https://www.shellcheck.net/>`_: A static analysis tool for shell scripts.
* `pre-commit <https://pre-commit.com/>`_: Runs all configured hooks in ``.pre-commit-config.yaml``.

It runs on ``ubuntu-latest`` and uses Go and Python 3.12 to install the necessary tools.
The linting is performed using the ``./lint_clean_files.sh`` script, which checks files listed in ``clean_files.txt``.

Lint Differential
^^^^^^^^^^^^^^^^^

This job runs a differential ShellCheck on pull requests, which only reports issues in the changed files.
It uses the `differential-shellcheck <https://github.com/redhat-plumbers-in-action/differential-shellcheck>`_ action.

Running CI checks locally
-------------------------

Most of the CI checks can be run locally:

* **Tests**: Run ``test/run`` (see :ref:`Testing Bash-it <test>` for more details).
* **Documentation**: Run ``sphinx-build -b html docs docs/_build/html`` (requires Sphinx and dependencies from ``docs/requirements.txt``).
* **Linting**: Run ``./lint_clean_files.sh`` (requires ``shfmt``, ``shellcheck``, and ``pre-commit``).
