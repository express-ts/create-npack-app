const execa = require('execa');
const fs = require('fs-extra');
const path = require('path');
const tempy = require('tempy');
const ReactScripts = require('./scripts');
const paths = require('./paths');

module.exports = class TestSetup {
  constructor(fixtureName, templateDirectory, { pnp = true } = {}) {
    this.fixtureName = fixtureName;

    this.templateDirectory = templateDirectory;
    this.testDirectory = null;
    this._scripts = null;

    this.setup = this.setup.bind(this);
    this.teardown = this.teardown.bind(this);

    this.isLocal = !(process.env.CI && process.env.CI !== 'false');
    this.settings = { pnp: pnp && !this.isLocal };
  }

  async setup() {
    await this.teardown();
    this.testDirectory = tempy.directory();
    await fs.copy(
      path.resolve(__dirname, '..', 'template'),
      this.testDirectory
    );
    await fs.copy(this.templateDirectory, this.testDirectory);
    await fs.remove(path.resolve(this.testDirectory, 'test.partial.js'));
    await fs.remove(path.resolve(this.testDirectory, '.disable-pnp'));

    const packageJson = await fs.readJson(
      path.resolve(this.testDirectory, 'package.json')
    );

    const shouldInstallScripts = !this.isLocal;
    if (shouldInstallScripts) {
      packageJson.dependencies = Object.assign({}, packageJson.dependencies, {
        'npack-scripts': 'latest',
      });
    }
    packageJson.scripts = Object.assign({}, packageJson.scripts, {
      start: 'npack-scripts start',
      build: 'npack-scripts build',
      test: 'npack-scripts test',
    });
    packageJson.license = packageJson.license || 'UNLICENSED';
    packageJson.entries = { index: paths.appIndexJs, };
    await fs.writeJson(
      path.resolve(this.testDirectory, 'package.json'),
      packageJson
    );

    await execa(
      'yarnpkg',
      [
        'install',
        this.settings.pnp ? '--enable-pnp' : null,
        '--mutex',
        'network',
      ].filter(Boolean),
      {
        cwd: this.testDirectory,
      }
    );

    if (!shouldInstallScripts) {
      await fs.ensureSymlink(
        path.resolve(
          path.resolve(
            __dirname,
            '../../../..',
            'packages',
            'npack-scripts',
            'bin',
            'npack-scripts.js'
          )
        ),
        path.join(this.testDirectory, 'node_modules', '.bin', 'npack-scripts')
      );
      await execa('yarnpkg', ['link', 'npack-scripts'], {
        cwd: this.testDirectory,
      });
    }
  }

  get scripts() {
    if (this.testDirectory == null) {
      return null;
    }
    if (this._scripts == null) {
      this._scripts = new ReactScripts(this.testDirectory);
    }
    return this._scripts;
  }

  async teardown() {
    if (this.testDirectory != null) {
      try {
        await fs.remove(this.testDirectory);
      } catch (ex) {
        if (this.isLocal) {
          throw ex;
        } else {
          // In CI, don't worry if the test directory was not able to be deleted
        }
      }
      this.testDirectory = null;
      this._scripts = null;
    }
  }
};
