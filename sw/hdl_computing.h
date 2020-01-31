/*
 * Copyright 2019 International Business Machines
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __HDL_COMPUTING__
#define __HDL_COMPUTING__

/*
 * This makes it obvious that we are influenced by HLS details ...
 * The ACTION control bits are defined in the following file.
 */
#define ACTION_TYPE_HDL_COMPUTING     0x1014300F	/* Action Type */

#define REG_SNAP_CONTROL        0x00
#define REG_SNAP_INT_ENABLE     0x04
#define REG_SNAP_ACTION_TYPE    0x10
#define REG_SNAP_ACTION_VERSION 0x14
#define REG_SNAP_CONTEXT        0x20
// User defined below
#define REG_USER_STATUS         0x30
#define REG_USER_CONTROL        0x34
#define REG_SOURCE_ADDRESS_L    0x38
#define REG_SOURCE_ADDRESS_H    0x3C
#define REG_TARGET_ADDRESS_L    0x40
#define REG_TARGET_ADDRESS_H    0x44
#define REG_MB_WIDTH_HEIGHT     0x48
#define REG_SOFT_RESET          0x50


#endif	/* __HDL_SINGLE_ENGINE__ */
