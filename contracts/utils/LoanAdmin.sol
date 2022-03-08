// @title Admin contract for NFTfi. Holds owner-only functions to adjust
//        contract-wide fees, parameters, etc.
// @author smartcontractdev.eth, creator of wrappedkitties.eth, cwhelper.eth, and
//         kittybounties.eth
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract LoanAdmin is Ownable, Pausable, ReentrancyGuard {

    /* ****** */
    /* EVENTS */
    /* ****** */

    // @notice This event is fired whenever the admins change the percent of
    //         interest rates earned that they charge as a fee. Note that
    //         newAdminFee can never exceed 10,000, since the fee is measured
    //         in basis points.
    // @param  newAdminFee - The new admin fee measured in basis points. This
    //         is a percent of the interest paid upon a loan's completion that
    //         go to the contract admins.
    event MarketFeeUpdated(
        uint256 newMarketFee
    );

    /* ******* */
    /* STORAGE */
    /* ******* */

    // @notice A mapping from from an NFT contract's address to whether that
    //         contract is whitelisted to be used by this contract. Note that
    //         NFTfi only supports loans that use NFT collateral from contracts
    //         that are whitelisted, all other calls to beginLoan() will fail.
    mapping (address => bool) public nftContractIsWhitelisted;

    // @notice The maximum duration of any loan started on this platform,
    //         measured in seconds. This is both a sanity-check for borrowers
    //         and an upper limit on how long admins will have to support v1 of
    //         this contract if they eventually deprecate it, as well as a check
    //         to ensure that the loan duration never exceeds the space alotted
    //         for it in the loan struct.
    uint256 public maximumLoanDuration = 53 weeks;

    // @notice The maximum number of active loans allowed on this platform.
    //         This parameter is used to limit the risk that NFTfi faces while
    //         the project is first getting started.
    uint256 public maximumNumberOfActiveLoans = 100;

    // @notice The percentage of interest earned by lenders on this platform
    //         that is taken by the contract admin's as a fee, measured in
    //         basis points (hundreths of a percent).
    uint256 public marketFeeInBasisPoints = 3;

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    constructor(address _characterAddress, address _weaponAddress) {
        // Whitelist mainnet CryptoKitties
        nftContractIsWhitelisted[_characterAddress] = true;
        nftContractIsWhitelisted[_weaponAddress] = true;
    }

    // @notice This function can be called by admins to change the whitelist
    //         status of an NFT contract. This includes both adding an NFT
    //         contract to the whitelist and removing it.
    // @param  _nftContract - The address of the NFT contract whose whitelist
    //         status changed.
    // @param  _setAsWhitelisted - The new status of whether the contract is
    //         whitelisted or not.
    function whitelistNFTContract(address _nftContract, bool _setAsWhitelisted) external onlyOwner {
        nftContractIsWhitelisted[_nftContract] = _setAsWhitelisted;
    }

    // @notice This function can be called by admins to change the
    //         maximumLoanDuration. Note that they can never change
    //         maximumLoanDuration to be greater than UINT32_MAX, since that's
    //         the maximum space alotted for the duration in the loan struct.
    // @param  _newMaximumLoanDuration - The new maximum loan duration, measured
    //         in seconds.
    function updateMaximumLoanDuration(uint256 _newMaximumLoanDuration) external onlyOwner {
        require(_newMaximumLoanDuration <= uint256(~uint32(0)), "loan duration cannot exceed space alotted in struct");
        maximumLoanDuration = _newMaximumLoanDuration;
    }

    // @notice This function can be called by admins to change the
    //         maximumNumberOfActiveLoans. 
    // @param  _newMaximumNumberOfActiveLoans - The new maximum number of
    //         active loans, used to limit the risk that NFTfi faces while the
    //         project is first getting started.
    function updateMaximumNumberOfActiveLoans(uint256 _newMaximumNumberOfActiveLoans) external onlyOwner {
        maximumNumberOfActiveLoans = _newMaximumNumberOfActiveLoans;
    }

    // @notice This function can be called by admins to change the percent of
    //         interest rates earned that they charge as a fee. Note that
    //         newMarketFee can never exceed 10,000, since the fee is measured
    //         in basis points.
    // @param  _newMarketFeeInBasisPoints - The new admin fee measured in basis points. This
    //         is a percent of the interest paid upon a loan's completion that
    //         go to the contract admins.
    function updateAdminFee(uint256 _newMarketFeeInBasisPoints) external onlyOwner {
        require(_newMarketFeeInBasisPoints <= 10000, "By definition, basis points cannot exceed 10000");
        marketFeeInBasisPoints = _newMarketFeeInBasisPoints;
        emit MarketFeeUpdated(_newMarketFeeInBasisPoints);
    }
}