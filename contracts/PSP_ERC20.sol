pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract PSP_ERC20 is ERC20Capped, ERC20Permit, AccessControlEnumerable {
    struct Supply {
        uint256 cap;
        uint256 total;
    }

    event MinterCapUpdated(address indexed minter, uint256 cap);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(address => Supply) public minterSupply;

    constructor() ERC20("ParaSwap", "PSP") ERC20Capped(2_000_000_000e18) ERC20Permit("ParaSwap") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
        super._mint(account, amount);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
        Supply storage s = minterSupply[msg.sender];
        s.total += amount;
        require(s.total <= s.cap, "minter cap exceeded");
        _mint(to, amount);
        return true;
    }

    function burn(address from, uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
        Supply storage s = minterSupply[msg.sender];
        s.total -= amount;
        _burn(from, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return getRoleMember(DEFAULT_ADMIN_ROLE, 0);
    }

    function getMinterCap(address minter) external view returns (uint256) {
        return minterSupply[minter].cap;
    }

    function setMinterCap(address minter, uint256 cap) external onlyRole(DEFAULT_ADMIN_ROLE) {
        minterSupply[minter].cap = cap;
        emit MinterCapUpdated(minter, cap);
    }
}
