# cusp-project-files writeup

Before running any scripts, dependencies need to be installed. You can do this
with `./install-dependencies.sh` to install the necessary requirements.

It is recommended to have a Github token when logging in with `gh auth login`
which can be done by logging into Github on the browser and navigating [here](https://github.com/settings/tokens).

Scripts that are used for static source code analysis leverage CodeQL and are
included in `codeql-cli` and `queries` so there is no extra setup required
for the scripts to function correctly. Included are queries downloaded on
04/19/2022 and CodeQL version 2.8.5. Be sure to pull these [files](https://drive.google.com/drive/u/0/folders/1cPSqjKlzzFfeZeT_-LjNTm2LsheBBUYF)
and unzip them in this directory. After doing so, run `./setup-codeql.sh` to
get CodeQL working.

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
and `run-codeql.sh` in that order. No additional arguments are necessary as `iter-repos.sh`
will pass them to the respective collection scripts using `repos.txt`. If you
would like to speed up static analysis, you can increase the number of threads
used by modifying the `-j` flag in `run-codeql.sh`, which is currently set to
6 for an 8-core machine.

Repo metadata results are stored in `./metadata/<repo-name>-data.csv`, randomly
selected PRs to be analyzed can be found in `./rands/<repo-name>-prnums.txt`,
and 15 PRs that contain the highest amount of code churn can be found in
`./topcc-prs/<repo-name>-ccprs.txt`.

Static analysis results from specified repos in `repos.txt` can be found in `./rand-results/<repo-name>`,
which are from randomly selected PRs, and in `./topcc-prs/<repo-name>`, which
are from 15 PRs that contain the highest amount of code churn.

If you would like to run the most up-to-date version of these tools, you can do
so by downloading the latest codeql-cli [here](https://github.com/github/codeql-cli-binaries/releases)
and latest queries repository [here](https://github.com/github/codeql).

However, per limitations of this study, the only queries used to collect data
are categorized as error queries in Python. This list can be found [here](./queries/python/ql/src/q.txt).
