package com.cinema.controller.food;


import com.cinema.dal.FoodDAO;
import com.cinema.entity.Food;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class FoodManagementServlet extends HttpServlet {

    private FoodDAO foodDAO;

    @Override
    public void init() throws ServletException {
        foodDAO = new FoodDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("getById".equals(action)) {
            getFoodById(request, response);
        } else if ("edit".equals(action)) {
            // Direct edit request
            getFoodById(request, response);
        } else {
            getAllFood(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "create":
                createFood(request, response);
                break;
            case "update":
                updateFood(request, response);
                break;
            case "delete":
                deleteFood(request, response);
                break;
            default:
                getAllFood(request, response);
        }
    }

    private void getAllFood(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Food> foodList = foodDAO.getAllFood();
        request.setAttribute("foodList", foodList);
        request.getRequestDispatcher("/pages/food/food.jsp").forward(request, response);
    }

    private void getFoodById(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int foodId = Integer.parseInt(request.getParameter("id"));
            Food food = foodDAO.getFoodById(foodId);

            if (food != null) {
                request.setAttribute("food", food);
                request.getRequestDispatcher("/pages/food/edit-food.jsp").forward(request, response);
            } else {
                response.sendRedirect("food-management?error=Food+not+found");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("food-management?error=Invalid+food+ID");
        } catch (Exception e) {
            response.sendRedirect("food-management?error=Server+error");
        }
    }

    private void createFood(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Food food = new Food();
            food.setFoodName(request.getParameter("foodName"));
            food.setDescription(request.getParameter("description"));
            food.setPrice(new BigDecimal(request.getParameter("price")));
            food.setFoodType(request.getParameter("foodType"));
            food.setImageURL(request.getParameter("imageURL"));
            food.setIsAvailable(Boolean.parseBoolean(request.getParameter("isAvailable")));

            boolean success = foodDAO.createFood(food);

            if (success) {
                response.sendRedirect("food-management?success=create");
            } else {
                response.sendRedirect("food-management?error=create");
            }
        } catch (Exception e) {
            response.sendRedirect("food-management?error=create");
        }
    }

    private void updateFood(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Food food = new Food();
            food.setFoodID(Integer.parseInt(request.getParameter("foodID")));
            food.setFoodName(request.getParameter("foodName"));
            food.setDescription(request.getParameter("description"));
            food.setPrice(new BigDecimal(request.getParameter("price")));
            food.setFoodType(request.getParameter("foodType"));
            food.setImageURL(request.getParameter("imageURL"));
            food.setIsAvailable(Boolean.parseBoolean(request.getParameter("isAvailable")));

            boolean success = foodDAO.updateFood(food);

            if (success) {
                response.sendRedirect("food-management?success=update");
            } else {
                response.sendRedirect("food-management?error=update");
            }
        } catch (Exception e) {
            response.sendRedirect("food-management?error=update");
        }
    }

    private void deleteFood(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int foodId = Integer.parseInt(request.getParameter("foodID"));
            boolean success = foodDAO.deleteFood(foodId);

            if (success) {
                response.sendRedirect("food-management?success=delete");
            } else {
                response.sendRedirect("food-management?error=delete");
            }
        } catch (Exception e) {
            response.sendRedirect("food-management?error=delete");
        }
    }
}
