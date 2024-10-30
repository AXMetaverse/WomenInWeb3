// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketplaceCore is Ownable {
    struct Listing {
        address seller;
        address assetContract;
        uint256 tokenId;
        uint256 minBidPrice;
        bool active;
    }

    struct Bid {
        address bidder;
        uint256 amount;
    }

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => Bid[]) public bids;
    uint256 public listingCount;

    address public daoAsheTreasury;
    uint256 public marketplaceFeePercentage;

    event AssetListed(uint256 indexed listingId, address indexed seller, address assetContract, uint256 tokenId, uint256 minBidPrice);
    event BidPlaced(uint256 indexed listingId, address indexed bidder, uint256 amount);
    event AssetSold(uint256 indexed listingId, address indexed buyer, address assetContract, uint256 tokenId, uint256 finalPrice);
    event ListingCanceled(uint256 indexed listingId);

    constructor(address _daoAsheTreasury) {
        daoAsheTreasury = _daoAsheTreasury;
        marketplaceFeePercentage = 0.5;
    }

    function listAsset(address assetContract, uint256 tokenId, uint256 minBidPrice) external {
        IERC721 asset = IERC721(assetContract);
        require(asset.ownerOf(tokenId) == msg.sender, "You are not the owner of this asset");
        require(asset.isApprovedForAll(msg.sender, address(this)), "Marketplace is not approved to transfer this asset");

        listings[listingCount] = Listing(msg.sender, assetContract, tokenId, minBidPrice, true);
        emit AssetListed(listingCount, msg.sender, assetContract, tokenId, minBidPrice);
        listingCount++;
    }

    function placeBid(uint256 listingId) external payable {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing is not active");
        require(msg.value >= listing.minBidPrice, "Bid amount is less than minimum bid price");

        bids[listingId].push(Bid(msg.sender, msg.value));
        emit BidPlaced(listingId, msg.sender, msg.value);
    }

    function finalizeAuction(uint256 listingId) external onlyOwner {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing is not active");
        require(bids[listingId].length > 0, "No bids placed for this listing");

        // Find the highest bid
        uint256 highestBidIndex = 0;
        for (uint256 i = 1; i < bids[listingId].length; i++) {
            if (bids[listingId][i].amount > bids[listingId][highestBidIndex].amount) {
                highestBidIndex = i;
            }
        }

        Bid memory highestBid = bids[listingId][highestBidIndex];
        uint256 marketplaceFee = (highestBid.amount * marketplaceFeePercentage) / 100;
        uint256 sellerProceeds = highestBid.amount - marketplaceFee;

        // Transfer funds
        payable(listing.seller).transfer(sellerProceeds);
        payable(daoAsheTreasury).transfer(marketplaceFee);

        // Transfer asset to the highest bidder
        IERC721(listing.assetContract).safeTransferFrom(listing.seller, highestBid.bidder, listing.tokenId);

        listing.active = false;
        emit AssetSold(listingId, highestBid.bidder, listing.assetContract, listing.tokenId, highestBid.amount);
    }

    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "You are not the seller of this listing");
        require(listing.active, "Listing is not active");

        listing.active = false;
        emit ListingCanceled(listingId);
    }

    function updateMarketplaceFeePercentage(uint256 _newFee) external onlyOwner {
        require(_newFee <= 10, "Fee percentage cannot exceed 10%");
        marketplaceFeePercentage = _newFee;
    }

    function updateTreasuryAddress(address _newDaoAsheTreasury) external onlyOwner {
        daoAsheTreasury = _newDaoAsheTreasury;
    }
}