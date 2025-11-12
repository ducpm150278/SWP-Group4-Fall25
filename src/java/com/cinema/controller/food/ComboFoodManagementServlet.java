package com.cinema.controller.food;


import com.cinema.dal.ComboDAO;
import com.cinema.dal.ComboFoodDAO;
import com.cinema.entity.Combo;
import com.cinema.entity.Food;
import com.cinema.utils.Constants;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author minhd
 */
public class ComboFoodManagementServlet extends HttpServlet {

    private ComboDAO comboDAO;
    private ComboFoodDAO comboFoodDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        comboDAO = new ComboDAO();
        comboFoodDAO = new ComboFoodDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        System.out.println("GET Action: " + action); // Debug log

        if (action == null || action.equals("view")) {
            viewComboFood(request, response);
        } else {
            response.sendRedirect("combo-management");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        System.out.println("POST Action: " + action); // Debug log

        if (action == null) {
            response.sendRedirect("combo-management");
            return;
        }

        try {
            switch (action) {
                case "add":
                    addFoodToCombo(request, response);
                    break;
                case "remove":
                    removeFoodFromCombo(request, response);
                    break;
                default:
                    response.sendRedirect("combo-management");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("combo-management?error=" + e.getMessage());
        }
    }

    private void viewComboFood(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String comboIdParam = request.getParameter("comboId");
            System.out.println("Combo ID: " + comboIdParam); // Debug log

            if (comboIdParam == null || comboIdParam.isEmpty()) {
                request.setAttribute("error", "Combo ID is required");
                response.sendRedirect("combo-management");
                return;
            }

            int comboId = Integer.parseInt(comboIdParam);

            // Get combo information
            Combo combo = comboDAO.getComboById(comboId);
            if (combo == null) {
                request.setAttribute("error", "Combo not found with ID: " + comboId);
                response.sendRedirect("combo-management");
                return;
            }

            // Get selected food items in the combo
            List<Food> selectedFoods = comboFoodDAO.getFoodItemsByComboId(comboId);
            System.out.println("Selected foods: " + selectedFoods.size()); // Debug log

            // Get available food items not in the combo
            List<Food> availableFoods = comboFoodDAO.getAvailableFoodItemsNotInCombo(comboId);
            System.out.println("Available foods: " + availableFoods.size()); // Debug log

            request.setAttribute("combo", combo);
            request.setAttribute("selectedFoods", selectedFoods);
            request.setAttribute("availableFoods", availableFoods);

            request.getRequestDispatcher(Constants.JSP_FOOD_COMBO_FOOD_EDIT).forward(request, response);

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid Combo ID format");
            response.sendRedirect("combo-management");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading combo food management: " + e.getMessage());
            response.sendRedirect("combo-management");
        }
    }

    private void addFoodToCombo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String comboIdParam = request.getParameter("comboId");
            String foodIdParam = request.getParameter("foodId");
            String quantityParam = request.getParameter("quantity");

            System.out.println("Add - ComboID: " + comboIdParam + ", FoodID: " + foodIdParam); // Debug log

            if (comboIdParam == null || foodIdParam == null) {
                response.sendRedirect("combo-food-management?action=view&comboId=" + comboIdParam + "&error=Missing parameters");
                return;
            }

            int comboId = Integer.parseInt(comboIdParam);
            int foodId = Integer.parseInt(foodIdParam);
            int quantity = 1;

            if (quantityParam != null && !quantityParam.isEmpty()) {
                quantity = Integer.parseInt(quantityParam);
            }

            // Add food to combo
            boolean success = comboFoodDAO.addFoodToCombo(comboId, foodId, quantity);

            if (success) {
                response.sendRedirect("combo-food-management?action=view&comboId=" + comboId + "&success=Food added successfully");
            } else {
                response.sendRedirect("combo-food-management?action=view&comboId=" + comboId + "&error=Failed to add food");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("combo-food-management?action=view&comboId=" + request.getParameter("comboId") + "&error=Invalid ID format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("combo-food-management?action=view&comboId=" + request.getParameter("comboId") + "&error=" + e.getMessage());
        }
    }

    private void removeFoodFromCombo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String comboIdParam = request.getParameter("comboId");
            String foodIdParam = request.getParameter("foodId");

            System.out.println("Remove - ComboID: " + comboIdParam + ", FoodID: " + foodIdParam); // Debug log

            if (comboIdParam == null || foodIdParam == null) {
                response.sendRedirect("combo-food-management?action=view&comboId=" + comboIdParam + "&error=Missing parameters");
                return;
            }

            int comboId = Integer.parseInt(comboIdParam);
            int foodId = Integer.parseInt(foodIdParam);

            // Remove food from combo
            boolean success = comboFoodDAO.removeFoodFromCombo(comboId, foodId);

            if (success) {
                response.sendRedirect("combo-food-management?action=view&comboId=" + comboId + "&success=Food removed successfully");
            } else {
                response.sendRedirect("combo-food-management?action=view&comboId=" + comboId + "&error=Failed to remove food");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("combo-food-management?action=view&comboId=" + request.getParameter("comboId") + "&error=Invalid ID format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("combo-food-management?action=view&comboId=" + request.getParameter("comboId") + "&error=" + e.getMessage());
        }
    }
}
