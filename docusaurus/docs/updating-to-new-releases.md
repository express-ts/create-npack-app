---
id: updating-to-new-releases
title: Updating to New Releases
---

Create Npack App is divided into two packages:

- `create-npack-app` is a global command-line utility that you use to create new projects.
- `npack-scripts` is a development dependency in the generated projects (including this one).

When you run `npx create-npack-app my-app` it automatically installs the latest version of Create Npack App.

> If you've previously installed `create-npack-app` globally via `npm install -g create-npack-app`, please visit [Getting Started](getting-started.md) to learn about current installation steps.

Create Npack App creates the project with the latest version of `npack-scripts` so you’ll get all the new features and improvements in newly created apps automatically.

To update an existing project to a new version of `npack-scripts`, [open the changelog](https://github.com/express-ts/create-npack-app/blob/master/CHANGELOG.md), find the version you’re currently on (check `package.json` in this folder if you’re not sure), and apply the migration instructions for the newer versions.

In most cases bumping the `npack-scripts` version in `package.json` and running `npm install` (or `yarn install`) in this folder should be enough, but it’s good to consult the [changelog](https://github.com/express-ts/create-npack-app/blob/master/CHANGELOG.md) for potential breaking changes.

We commit to keeping the breaking changes minimal so you can upgrade `npack-scripts` painlessly.
