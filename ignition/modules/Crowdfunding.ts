// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const CrownFunding = buildModule("CrownFunding", (m) => {

  const CrownFunding = m.contract("CrownFunding");

  return { CrownFunding };
});

export default CrownFunding;
