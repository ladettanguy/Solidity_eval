// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.7.0 <0.9.0;
 

contract Marketplace {

    // évennement déclanché à des moments clé
    event ProductAdded(uint256 id, string name, uint256 cost, address seller);
    event ProductBought(uint256 id, string name, uint256 cost, address seller, address buyer);

    // Struct product permettant de stocké les produits mis en vente par quelqu'un
    uint256 private id_counteur = 0;
    struct Product {
        uint256 id;
        string name;
        uint256 cost;
        bool selled;
        address seller;
    }

    function createProduct(string calldata name, uint256 cost, address seller) private returns (Product memory)
    {
        Product memory p = Product(id_counteur, name, cost, false, seller);
        id_counteur += 1;
        return p;
    }

    // Array de Product, permettant de suivre les produits disponible (la variable est public)
    Product[] public products;
    // Mapping servant de compte d'argent disponible par address
    mapping(address=>uint256) public balance;
    // Mapping id_produit pour un produit. Permet de retrouvé un produit en vente grace a son id.
    mapping(uint256=>Product) private id_produit_map;


    // fonction de mise en vente d'un produit.
    function sellProduct(string calldata name, uint256 cost) public {
        Product memory product = createProduct(name, cost, msg.sender);
        id_produit_map[product.id] = product;
        products.push(product);

        // Déclanche l'évenement d'ajout de produit en vente
        emit ProductAdded(product.id, product.name, product.cost, product.seller);
    }


    // fonction d'achat d'un produit
    function buyProduct(uint id_product) public returns (bool){
        Product memory product = id_produit_map[id_product];
        require(balance[msg.sender] > product.cost, "Not enough");
        // vérification que l'acheteur peu acheté
        if (product.cost < balance[msg.sender]) 
        { 
            // retire l'argent disponible dans la balance de l'acheteur
            _removeBalanceFromAddress(msg.sender, product.cost);
            // crédite l'argent dans le compte du vendeur
            _addBalanceFromAddress(product.seller, product.cost);


            // déclanche l'evenement de produit acheté
            emit ProductBought(product.id, product.name, product.cost, product.seller, msg.sender);

            // Suppression du produit dans la liste de vente de produit
            product.selled = true;
            delete id_produit_map[product.id];
            return true;
        }
        else {
            return false;
        }
    }

    function getBalance() public view returns(uint256){
        return balance[msg.sender];
    }

    function addBalance() public payable {
        _addBalanceFromAddress(msg.sender, msg.value);
    }

    function _removeBalanceFromAddress(address addr, uint256 amount) private
    {
        require(balance[addr] > amount, "Not enough");
        balance[addr] -= amount;
    }

    function _addBalanceFromAddress(address addr, uint256 amount) private {
        balance[addr] += amount;
    }

}
