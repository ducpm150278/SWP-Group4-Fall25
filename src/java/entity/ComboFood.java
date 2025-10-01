/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

public class ComboFood {
    private Integer comboFoodID;
    private Integer comboID;
    private Integer foodID;
    private Integer quantity;

    public ComboFood() {}

    public ComboFood(Integer comboFoodID, Integer comboID, Integer foodID, Integer quantity) {
        this.comboFoodID = comboFoodID;
        this.comboID = comboID;
        this.foodID = foodID;
        this.quantity = quantity;
    }

    // Getters and Setters
    public Integer getComboFoodID() { return comboFoodID; }
    public void setComboFoodID(Integer comboFoodID) { this.comboFoodID = comboFoodID; }

    public Integer getComboID() { return comboID; }
    public void setComboID(Integer comboID) { this.comboID = comboID; }

    public Integer getFoodID() { return foodID; }
    public void setFoodID(Integer foodID) { this.foodID = foodID; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
}