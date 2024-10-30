**DAO Ashé NFT Marketplace Smart Contract**

This repository contains the DAO Ashé Marketplace smart contract, which allows users to list, bid, and auction NFTs (ERC-721 tokens) in a decentralized manner. The marketplace also facilitates a marketplace fee for every sale, which goes to the DAO’s treasury.

✨ Features

**Listing NFTs**: Sellers can list their NFTs for auction by specifying a minimum bid price.

**Bidding**: Users can place bids on NFTs. The highest bid is tracked throughout the auction.

**Finalizing Auctions**: The contract owner finalizes auctions, awarding the NFT to the highest bidder.

**Marketplace Fees**: A percentage of the sale is sent to the DAO's treasury as a fee (default is 0.5%)

**Canceling Listings**: Sellers can cancel their listings before the auction is finalized.

📜 Contract Details

Contract Name: MarketplaceCore

License: MIT
Solidity Version: ^0.8.0
External Libraries: OpenZeppelin Contracts

Uses OpenZeppelin's ERC721 interface and Ownable contract
.
🚀 Main Functions

1. listAsset(address assetContract, uint256 tokenId, uint256 minBidPrice)
Description: Allows the owner of an NFT (ERC-721 token) to list it on the marketplace.
Parameters:
assetContract: Address of the NFT contract.
tokenId: The unique identifier of the NFT.
minBidPrice: The minimum bid price for the auction.

2. placeBid(uint256 listingId)
Description: Allows a user to place a bid on a listed NFT.
Parameters:
listingId: The ID of the NFT listing.
Requirements:
The bid must be greater than or equal to the minimum bid price.

3. finalizeAuction(uint256 listingId)
Description: Finalizes the auction, transferring the NFT to the highest bidder and distributing the funds.
Parameters:
listingId: The ID of the NFT listing.
Access Control: Only the contract owner (DAO admin) can call this function.

4. cancelListing(uint256 listingId)
Description: Allows the seller to cancel the listing before the auction is finalized.
Parameters:
listingId: The ID of the NFT listing.

5. updateMarketplaceFeePercentage(uint256 newFee)
Description: Allows the contract owner to update the marketplace fee percentage.
Parameters:
newFee: The new marketplace fee percentage (cannot exceed 10%).

📅 Events
AssetListed(uint256 listingId, address seller, address assetContract, uint256 tokenId, uint256 minBidPrice)
Emitted when an asset is listed for auction.

BidPlaced(uint256 listingId, address bidder, uint256 amount)
Emitted when a bid is placed.

AssetSold(uint256 listingId, address buyer, address assetContract, uint256 tokenId, uint256 finalPrice)
Emitted when an auction is finalized and the asset is transferred to the highest bidder.

ListingCanceled(uint256 listingId)
Emitted when a listing is canceled by the seller.

📊 Variables & Configurations
listingCount: Tracks the total number of listings created on the marketplace.
daoAsheTreasury: The treasury address where marketplace fees are sent.
marketplaceFeePercentage: The percentage fee taken from each auction sale (default is 0.5%).

🔐 Security Considerations
Owner Only Functions: Only the contract owner (likely the DAO admin) can finalize auctions and modify fees.
Ownership Verification: Only the owner of an NFT can list or cancel it.
Reentrancy Protection: Consider adding reentrancy guards for safety in more complex versions.