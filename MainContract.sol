// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDiamondInvestment {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

interface IDiamondCut is IDiamondInvestment {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;
}

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}

/**
 * @title
 * @authors
 */
contract MainContract {

    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    mapping (bytes4 => address) selectorTofacet;    

    constructor(){
        selectorTofacet[bytes4(0xd2)] = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    }

    function diamondCut(        
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    )external{
        for(uint8 faceLoop = 0; faceLoop < _diamondCut.length; faceLoop++){
            FacetCut memory itemToBeCut = _diamondCut[faceLoop];
            //Add the items
            if(itemToBeCut.action == FacetCutAction(0)){
                for(uint8 itemLoop = 0; itemLoop < itemToBeCut.functionSelectors.length; itemLoop++){
                    selectorTofacet[itemToBeCut.functionSelectors[itemLoop]] = itemToBeCut.facetAddress;
                }
                break;
            //Replace the item
            }else if(itemToBeCut.action == FacetCutAction(1)){
                for(uint8 itemLoop = 0; itemLoop < itemToBeCut.functionSelectors.length; itemLoop++){
                    selectorTofacet[itemToBeCut.functionSelectors[itemLoop]] = itemToBeCut.facetAddress;
                }
                break;
            //Remove the item
            }else{
                for(uint8 itemLoop = 0; itemLoop < itemToBeCut.functionSelectors.length; itemLoop++){
                    selectorTofacet[itemToBeCut.functionSelectors[itemLoop]] = address(0);
                }
                break;
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
    }

    /**
     * @dev Find facet for function that is called and execute the
     *      function if a facet is found and return any value.
     */
    fallback() external payable {
        // get facet from function selector
        address facet = selectorTofacet[msg.sig];
        require(facet != address(0), "Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }
}
