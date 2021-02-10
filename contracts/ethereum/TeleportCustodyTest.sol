// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TeleportCustody.sol";

contract TeleportCustodyTest is TeleportCustody {
  constructor(address revvTokenAddress) 
    public
  {
    _tokenContract = ERC20(revvTokenAddress);
  }
}
