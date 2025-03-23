// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/Ownable.sol";

// TokenRecover Contract (original)
contract TokenRecover is Ownable {
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public virtual onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}

// Platformofmemecoins Contract (original, with adjustments to make it compilable)
contract Platformofmemecoins is ERC20, TokenRecover {
    uint256 public Optimization = 131200614461891778321580308148927;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 initialBalance_,
        address tokenOwner,
        address payable feeReceiver_
    ) payable ERC20(name_, symbol_) {
        payable(feeReceiver_).transfer(msg.value);
        // _owner = tokenOwner dihapus karena _owner private di Ownable
        // Kepemilikan tetap pada deployer dari konstruktor Ownable
        _mint(tokenOwner, initialBalance_ * 10**decimals_);
    }
}

// Standard ERC20 token for simulation
contract StandardToken is ERC20 {
    constructor() ERC20("StandardToken", "STK") {
        _mint(msg.sender, 1000 * 10**18);
    }
}

// Non-standard tokens that do not emit events
contract NonStandardToken {
    mapping(address => uint256) private balances;

    constructor() {
        balances[msg.sender] = 1000 * 10**18;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        // Tidak ada event Transfer
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

// Tester contract
contract TestRecover {
    Platformofmemecoins public platform;
    StandardToken public standardToken;
    NonStandardToken public nonStandardToken;
    address public deployer;

    constructor(address tokenOwner, address payable feeReceiver) payable {
        deployer = msg.sender;
        platform = new Platformofmemecoins{value: msg.value}(
            "MemeCoin",
            "MEME",
            18,
            1000,
            tokenOwner,
            feeReceiver
        );
        standardToken = new StandardToken();
        nonStandardToken = new NonStandardToken();

        // Kirim token ke kontrak Platformofmemecoins
        standardToken.transfer(address(platform), 500 * 10**18);
        nonStandardToken.transfer(address(platform), 500 * 10**18);
    }

    function recoverStandardToken(uint256 amount) public {
        platform.recoverERC20(address(standardToken), amount);
    }

    function recoverNonStandardToken(uint256 amount) public {
        platform.recoverERC20(address(nonStandardToken), amount);
    }

    function getPlatformOwner() public view returns (address) {
        return platform.owner();
    }

    function getStandardTokenBalance(address account) public view returns (uint256) {
        return standardToken.balanceOf(account);
    }

    function getNonStandardTokenBalance(address account) public view returns (uint256) {
        return nonStandardToken.balanceOf(account);
    }
}
