// This file is part of MinIO Console Server
// Copyright (c) 2021 MinIO, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import React, { Fragment } from "react";
import { Grid, HelpBox, LicenseIcon, PageLayout } from "mds";
import PageHeaderWrapper from "../Common/PageHeaderWrapper/PageHeaderWrapper";


const License = () => {
  return (
    <Fragment>
      <PageHeaderWrapper label={"Configuration"} />
      <PageLayout>
        <Grid item xs={12}>
          <HelpBox
            title={"License"}
            iconComponent={<LicenseIcon />}
            help={
              <Fragment>
                <p>
                  MinIO Console is licensed under the GNU Affero General Public License (AGPL) Version 3.0.
                </p>
                <p>
                  For more information, please refer to the license at <a href="https://www.gnu.org/licenses/agpl-3.0.en.html" target="_blank">https://www.gnu.org/licenses/agpl-3.0.en.html</a>.
                </p>
              </Fragment>
            }
          />
        </Grid>
      </PageLayout>
    </Fragment>
  );
};

export default License;
