// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Method signature contract for Tether (USDT) because it's not a standard
 * ERC-20 contract and have different method signatures.
 */
contract REVVTokenTest is ERC20("REVV", "REVV") {
  function transfer(address _to, uint _value)
    override
    public
    returns (bool)
  {
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value)
    override
    public
    returns (bool)
  {
    emit Transfer(_from, _to, _value);
    return true;
  }
}
