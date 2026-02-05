Contributing to PLOTS2
==========================

We welcome community contributions to PLOTS2! To install PLOTS2 locally, follow the instructions in the [README.md file](https://github.com/publiclab/plots2#installation).

We especially welcome contributions from people from groups underrepresented in free and open source software!

Our community aspires to be a respectful place. Please read and abide by our [Code of Conduct](https://publiclab.org/conduct).

## First Timers Welcome!

New to open source/free software? See our WELCOME PAGE, including a selection of issues we've made especially for first-timers. We're here to help, so just ask if one looks interesting:

https://code.publiclab.org/#r=all

Thank you so much!

Learn more about contributing to Public Lab code projects on these pages:

* https://publiclab.org/developers
* https://publiclab.org/contributing-to-public-lab-software
* https://publiclab.org/soc
* https://publiclab.org/wiki/developers
* https://publiclab.org/wiki/gsoc-ideas

## Bug reports & troubleshooting

If you are submitting a bug/issue , please go to https://github.com/publiclab/plots2/issues/new

Follow the [First Timers Issue Template](https://github.com/publiclab/plots2/blob/main/.github/ISSUE_TEMPLATE/--first-timers-only.md) for submitting First Timers Only issues.

Follow this standard [Issue Template](https://github.com/publiclab/plots2/blob/main/.github/ISSUE_TEMPLATE/ISSUE_TEMPLATE.md) for other issues.

---

## Common Setup Issues (Windows)

Some contributors may face setup issues on Windows while installing PLOTS2 locally. Below are a few common problems and suggested solutions:

### PowerShell script execution error
If you see an error like:
`running scripts is disabled on this system`

You can fix it by running PowerShell as Administrator and executing:
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Node.js and npm version compatibility
We recommend using **Node.js 16** for local development, as newer versions may cause dependency resolution issues.

### npm dependency resolution errors
If `npm install` fails due to dependency conflicts, try:
```
npm install --legacy-peer-deps
```

These steps can help first-time contributors get the project running more smoothly on Windows systems.
