/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import React from 'react';

const FileEnvVariables = () => (
  <span>
    <span id="feature-file-env-original-1">
      {process.env.EXPRESS_APP_ORIGINAL_1}
    </span>
    <span id="feature-file-env-original-2">
      {process.env.EXPRESS_APP_ORIGINAL_2}
    </span>
    <span id="feature-file-env">
      {process.env.EXPRESS_APP_DEVELOPMENT}
      {process.env.EXPRESS_APP_PRODUCTION}
    </span>
    <span id="feature-file-env-x">{process.env.EXPRESS_APP_X}</span>
  </span>
);

export default FileEnvVariables;
