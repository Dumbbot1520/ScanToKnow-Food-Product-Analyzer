import 'package:main_project_files/models/product_model.dart';

List<ProductModel> getProducts() {
  return [
    // 🟢 Healthy
    ProductModel(name: "Horlicks", image: "images/packet_images/horlicks.png", health: "Green", nutriScore: "A", novaScore: 1, price: 120),
    ProductModel(name: "Maggi", image: "images/packet_images/maggi.png", health: "Green", nutriScore: "B", novaScore: 2, price: 25),
    ProductModel(name: "Amul Pro", image: "images/packet_images/amul_pro.webp", health: "Green", nutriScore: "A", novaScore: 1, price: 100),
    ProductModel(name: "Fanta", image: "images/packet_images/fanta.png", health: "Green", nutriScore: "B", novaScore: 2, price: 50),

    // 🟡 Moderate
    ProductModel(name: "Lays Chips", image: "images/packet_images/lays.png", health: "Yellow", nutriScore: "C", novaScore: 3, price: 30),
    ProductModel(name: "Coca Cola", image: "images/packet_images/coca_cola.png", health: "Yellow", nutriScore: "D", novaScore: 4, price: 40),
    ProductModel(name: "Diet Coke", image: "images/packet_images/diet_coke.png", health: "Yellow", nutriScore: "C", novaScore: 3, price: 40),
    ProductModel(name: "Doritos", image: "images/packet_images/doritos.png", health: "Yellow", nutriScore: "C", novaScore: 3, price: 35),
    ProductModel(name: "Pringles Original", image: "images/packet_images/pringles_original.png", health: "Yellow", nutriScore: "C", novaScore: 3, price: 60),
    ProductModel(name: "McCain Fries", image: "images/packet_images/mc_cain.png", health: "Yellow", nutriScore: "C", novaScore: 3, price: 50),

    // 🔴 Unhealthy
    ProductModel(name: "KitKat", image: "images/packet_images/kitkat.png", health: "Red", nutriScore: "E", novaScore: 4, price: 60),
    ProductModel(name: "Kinder Joy", image: "images/packet_images/kinder_joy.png", health: "Red", nutriScore: "D", novaScore: 4, price: 30),
    ProductModel(name: "Ferrero Rocher", image: "images/packet_images/ferero_rocher.png", health: "Red", nutriScore: "E", novaScore: 4, price: 150),
    ProductModel(name: "Bounty", image: "images/packet_images/bounty.png", health: "Red", nutriScore: "E", novaScore: 4, price: 40),
    ProductModel(name: "Cheetos", image: "images/packet_images/cheetos.png", health: "Red", nutriScore: "D", novaScore: 4, price: 35),
    ProductModel(name: "Snickers", image: "images/packet_images/snickers.png", health: "Red", nutriScore: "E", novaScore: 4, price: 50),
    ProductModel(name: "Dairy Milk Whole Nut", image: "images/packet_images/dairy_milk_whole_nut.png", health: "Red", nutriScore: "E", novaScore: 4, price: 60),
    ProductModel(name: "Hershey’s Kisses", image: "images/packet_images/kisses.png", health: "Red", nutriScore: "E", novaScore: 4, price: 70),
    ProductModel(name: "McCain Nuggets", image: "images/packet_images/mc_cain2.png", health: "Red", nutriScore: "D", novaScore: 4, price: 55),
    ProductModel(name: "Coca Cola Can", image: "images/packet_images/coca_cola_can.png", health: "Red", nutriScore: "E", novaScore: 4, price: 35),
  ];
}
