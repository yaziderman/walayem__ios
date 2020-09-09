//
//  DatabaseHandler.swift
//  Walayem
//
//  Created by MAC on 5/7/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation
import SQLite

class DatabaseHandler{
    
    let db: Connection?
    
    // Table name
    let cartChef = Table("chef")
    let cartFood = Table("food")
    
    // Columns name
    let id = Expression<Int>("id")
    let chefId = Expression<Int>("chef_id")
    let name = Expression<String>("name")
    let kitchen = Expression<String>("kitchen")
    let image = Expression<String>("image")
    let price = Expression<Double>("price")
    let quantity = Expression<Int>("quantity")
    let preparationTime = Expression<Int>("preparationTime")
    
    // MARK: Initialization
    
    init(){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
            db = try Connection("\(path)/walayem.sqlite")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        createTable()
    }
    
    private func createTable(){
        do {
            try db!.run(cartChef.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(image)
                table.column(kitchen)
            })
            
            try db!.run(cartFood.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(chefId)
                table.column(name)
                table.column(price)
                table.column(quantity)
                table.column(preparationTime)
                table.foreignKey(chefId, references: cartChef, id)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    // MARK: Database methods
    
    func addFoodDirectly(item: Food) -> Int{

        let cartItem = cartFood.filter(id == item.id ?? 0)
        // Add quantity if food already existe in cart
        do{
            if try db!.run(cartItem.update(quantity += 1)) > 0{
                return 1
            }
        }catch let error{
            print ("Update Failed \(error)")
            return -1
        }
        // ====================
        
        addChef(chefId: item.chefId!, chefName: item.chefName!, chefImage: item.chefImage!, kitchen: item.kitcherName!)
        do{
            let insert = cartFood.insert(self.id <- item.id ?? 0, chefId <- item.chefId!, name <- item.name ?? "", price <- Double(item.price ?? 0.0), quantity <- 1, preparationTime <- item.preparationTime)
            let id = try db!.run(insert)
            return Int(id)
        }catch let error{
            print ("Insert failed \(error)")
            return -1
        }
    }
    
    func addFood(item: Food) -> Int{
        let cartItem = cartFood.filter(id == item.id ?? 0)
        // Add quantity if food already existe in cart
        do{
            if try db!.run(cartItem.update(quantity += item.quantity)) > 0{
                return 1
            }
        }catch let error{
            print ("Update Failed \(error)")
            return -1
        }
        print(item.chefImage)
        // ====================
        
        addChef(chefId: item.chefId!, chefName: item.chefName!, chefImage: item.chefImage!, kitchen: item.kitcherName!)
        do{
            let insert = cartFood.insert(self.id <- item.id ?? 0, chefId <- item.chefId!, name <- item.name ?? "", price <- Double(item.price ?? 0.0), quantity <- item.quantity, preparationTime <- item.preparationTime)
            let id = try db!.run(insert)
            return Int(id)
        }catch let error{
            print ("Insert failed \(error)")
            return -1
        }
    }
    
    func addChef(chefId: Int, chefName: String, chefImage: String, kitchen: String){
        do{
            let count = try db!.scalar(cartChef.filter(id == chefId).count)
            if count == 0{
                let insert = cartChef.insert(self.id <- chefId, name <- chefName, image <- chefImage, self.kitchen <- kitchen)
                try db!.run(insert)
            }
        } catch let error {
            print("Insert failed \(error)")
        }
    }
    
    func getChefIdsFromCart() -> [Int] {
        var chefIds = [Int]()
        do{
            for mItems in try db!.prepare(self.cartFood) {
                chefIds.append(mItems[chefId])
            }
        } catch{
            print ("Select query failed")
        }
        let unique = Array(Set(chefIds))
        return unique
    }
    
    func getCartItemsByChefId(_ chefID: Int) -> [Chef]{
        var cartItems = [Chef]()
        do{
            // get chefs in cart
            for item in try db!.prepare(self.cartChef){
                let id: Int = item[self.id]
                var foods = [Food]()
                if id == chefID {
                    for foodItem in try db!.prepare(self.cartFood.filter(chefId == id)){
                        let food = Food(id: foodItem[self.id],
                                        name: foodItem[name],
                                        price: foodItem[price],
                                        quantity: foodItem[quantity],
										preparationTime: foodItem[preparationTime], isWebsiteActive: false)
                        foods.append(food)
                    }
                    let chef = Chef(id: id,
                                    name: item[name],
                                    image: item[image],
                                    kitchen: item[kitchen],
                                    foods: foods)
                    cartItems.append(chef)
                }
                // get foods of chef
            }
        } catch{
            print ("Select query failed")
        }
        return cartItems
    }
    func getCartItems() -> [Chef]{
        var cartItems = [Chef]()
        do{
            // get chefs in cart
            for item in try db!.prepare(self.cartChef){
                let id: Int = item[self.id]
                var foods = [Food]()
                // get foods of chef
                for foodItem in try db!.prepare(self.cartFood.filter(chefId == id)){
                    let food = Food(id: foodItem[self.id],
                                    name: foodItem[name],
                                    price: foodItem[price],
                                    quantity: foodItem[quantity],
									preparationTime: foodItem[preparationTime], isWebsiteActive: false)
                    foods.append(food)
                }
                
                let chef = Chef(id: id,
                                name: item[name],
                                image: item[image],
                                kitchen: item[kitchen],
                                foods: foods)
                cartItems.append(chef)
            }
        }catch{
            print ("Select query failed")
        }
        return cartItems
    }
    
    func getFoods() -> [Food]{
        var foods = [Food]()
        do{
            for foodItem in try db!.prepare(self.cartFood){
                let food = Food(id: foodItem[self.id],
                                name: foodItem[name],
                                price: foodItem[price],
                                quantity: foodItem[quantity],
								preparationTime: foodItem[preparationTime], isWebsiteActive: false)
                foods.append(food)
            }
        }catch let error{
            print ("Select query failed \(error)")
        }
        return foods
    }
    
    func addQuantity(foodId: Int) -> Bool{
        let item = cartFood.filter(id == foodId)
        do{
            if try db!.run(item.update(quantity++)) > 0{
                return true
            }
        }catch{
            print ("Unable to update row")
        }
        
        return false
    }
    
    func subtractQuantity(foodId: Int) -> Bool{
        let item = cartFood.filter(id == foodId)
        do{
            if try db!.run(item.update(quantity--)) > 0{
                return true
            }
        }catch{
            print ("Unable to update row")
        }
        return false
    }
    
    func subtractFoodDirectly(foodId: Int) -> Bool{
        let item = cartFood.filter(id == foodId)
        do{
            if let food = try db?.pluck(item){
                if food[quantity] == 1{
                    return removeFood(foodId: foodId)
                }
            }
            if try db!.run(item.update(quantity--)) > 0{
                return true
            }
        }catch{
            print ("Unable to update row")
        }
        return false
    }
    
    func removeFood(foodId: Int) -> Bool{
        let item = cartFood.filter(id == foodId)
        do{
            try db?.transaction {
                let food = try db!.pluck(item)
                try db!.run(item.delete())
                removeChef(chefId: food![chefId])
            }
            return true
        }catch{
            print ("Unable to delete item")
        }
        return false
    }
    
    func removeChef(chefId: Int){
        do{
            let count = try db!.scalar(cartFood.filter(self.chefId == chefId).count)
            if count == 0{
                let item = cartChef.filter(id == chefId)
                try db?.run(item.delete())
            }
        }catch let error{
            print ("CRUD error \(error)")
        }
    }
    
    func getFoodsCount() -> String?{
        do{
            let count = try db!.scalar(cartFood.count)
            if count > 0{
                return String(count)
            }else{
                return nil
            }
        }catch let error{
            print ("Query error \(error)")
            return nil
        }
    }
    
    func clearDatabase(){
        do{
            try db?.run(cartChef.delete())
            try db?.run(cartFood.delete())
        }catch{
            print ("Unable to clear all data")
        }
    }
}
