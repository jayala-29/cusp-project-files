# cusp-project-files

Before running any scripts, dependencies need to be installed. You can do this
with `./install-dependencies.sh` to install the necessary requirements.

It is recommended to have a Github token when logging in with `gh auth login`
which can be done by logging into Github on the browser and navigating [here](https://github.com/settings/tokens)

Afterwards, the required directory setup can be made with `./setup-dirs.sh`
which will create the following:

- pr-nums
- metadata
- rands
- topcc-prs
- repos
- databases
- rand-results
- cc-results

For a one-click run to generate results, `repos.txt` must contain target repo
authors and the repo name itself in the `<repo-author>/<repo-name>` format. An
example of this is as follows in `repos.txt`:

```
OctoPrint/OctoPrint
Ultimaker/Cura
Klipper3d/klipper
kubernetes-client/python
```

After this is done, simply run `./iter-repos.sh` which will call `collect-metadata.sh`
and `run-codeql.sh` in that order.

Scripts that are used for static source code analysis leverage CodeQL and are
included in `codeql-cli` and `queries` so there is no extra setup required
for the scripts to function correctly. Included are queries downloaded on  
04/19/2022 and CodeQL version 2.8.5.
