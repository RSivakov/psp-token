pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract PSP_BEP20 is ERC20Capped, ERC20Permit, AccessControlEnumerable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("ParaSwap", "PSP") ERC20Capped(2_000_000_000e18) ERC20Permit("ParaSwap") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
        super._mint(account, amount);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
        _mint(to, amount);
        return true;
    }

    function burn(address from, uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
        _burn(from, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return getRoleMember(DEFAULT_ADMIN_ROLE, 0);
    }
}
