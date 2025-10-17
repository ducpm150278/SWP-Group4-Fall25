/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
/**
 *
 * @author minhd
 */
package controller;

import dal.ComboDAO;
import dal.FoodDAO;
import entity.Combo;
import entity.Food;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ComboManagementServlet extends HttpServlet {

    private ComboDAO comboDAO;
    private FoodDAO foodDAO;

    @Override
    public void init() throws ServletException {
        comboDAO = new ComboDAO();
        foodDAO = new FoodDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("getById".equals(action)) {
            getComboById(request, response);
        } else if ("edit".equals(action)) {
            getComboById(request, response);
        } else if ("showAddForm".equals(action)) {
            showAddComboForm(request, response);
        } else {
            getAllCombos(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "create":
                createCombo(request, response);
                break;
            case "update":
                updateCombo(request, response);
                break;
            case "delete":
                deleteCombo(request, response);
                break;
            default:
                getAllCombos(request, response);
        }
    }

    private void getAllCombos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Combo> comboList = comboDAO.getAllCombos();
        List<Food> availableFood = foodDAO.getAvailableFood(); // Thêm dòng này

        request.setAttribute("comboList", comboList);
        request.setAttribute("availableFood", availableFood); // Thêm dòng này
        request.getRequestDispatcher("/combo.jsp").forward(request, response);
    }

    private void getComboById(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int comboId = Integer.parseInt(request.getParameter("id"));
            Combo combo = comboDAO.getComboById(comboId);

            if (combo != null) {
                request.setAttribute("combo", combo);
                request.getRequestDispatcher("/edit-combo.jsp").forward(request, response);
            } else {
                response.sendRedirect("combo-management?error=Combo+not+found");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("combo-management?error=Invalid+combo+ID");
        } catch (Exception e) {
            response.sendRedirect("combo-management?error=Server+error");
        }
    }

    private void showAddComboForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Food> availableFood = comboDAO.getAvailableFoodForCombo();
            request.setAttribute("availableFood", availableFood);
            request.getRequestDispatcher("/add-combo.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("combo-management?error=Error+loading+form: " + e.getMessage());
        }
    }

    private void createCombo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // 1. Tạo combo trước
            Combo combo = new Combo();
            combo.setComboName(request.getParameter("comboName"));
            combo.setDescription(request.getParameter("description"));
            combo.setTotalPrice(new BigDecimal(request.getParameter("totalPrice")));

            String discountPriceStr = request.getParameter("discountPrice");
            if (discountPriceStr != null && !discountPriceStr.trim().isEmpty()) {
                combo.setDiscountPrice(new BigDecimal(discountPriceStr));
            }

            combo.setComboImage(request.getParameter("comboImage"));
            combo.setIsAvailable(Boolean.parseBoolean(request.getParameter("isAvailable")));

            boolean comboCreated = comboDAO.createCombo(combo);

            if (!comboCreated) {
                response.sendRedirect("combo-management?action=showAddForm&error=create_combo_failed");
                return;
            }

            // 2. Thêm food vào combo (nếu có)
            String[] selectedFoodIds = request.getParameterValues("selectedFoods");
            if (selectedFoodIds != null && selectedFoodIds.length > 0) {
                for (String foodIdStr : selectedFoodIds) {
                    int foodId = Integer.parseInt(foodIdStr);
                    int quantity = 1; // Default quantity

                    String quantityParam = request.getParameter("quantity_" + foodId);
                    if (quantityParam != null && !quantityParam.trim().isEmpty()) {
                        quantity = Integer.parseInt(quantityParam);
                    }

                    boolean foodAdded = comboDAO.addFoodToCombo(combo.getComboID(), foodId, quantity);
                    if (!foodAdded) {
                        // Continue even if one food fails to add
                        System.err.println("Failed to add food " + foodId + " to combo " + combo.getComboID());
                    }
                }
            }

            response.sendRedirect("combo-management?success=create");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("combo-management?action=showAddForm&error=create");
        }
    }

    private void updateCombo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Combo combo = new Combo();
            combo.setComboID(Integer.parseInt(request.getParameter("comboID")));
            combo.setComboName(request.getParameter("comboName"));
            combo.setDescription(request.getParameter("description"));
            combo.setTotalPrice(new BigDecimal(request.getParameter("totalPrice")));

            String discountPriceStr = request.getParameter("discountPrice");
            if (discountPriceStr != null && !discountPriceStr.trim().isEmpty()) {
                combo.setDiscountPrice(new BigDecimal(discountPriceStr));
            } else {
                combo.setDiscountPrice(null);
            }

            combo.setComboImage(request.getParameter("comboImage"));
            combo.setIsAvailable(Boolean.parseBoolean(request.getParameter("isAvailable")));

            boolean success = comboDAO.updateCombo(combo);

            if (success) {
                response.sendRedirect("combo-management?success=update");
            } else {
                response.sendRedirect("combo-management?error=update");
            }
        } catch (Exception e) {
            response.sendRedirect("combo-management?error=update");
        }
    }

    private void deleteCombo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int comboId = Integer.parseInt(request.getParameter("comboID"));
            boolean success = comboDAO.deleteCombo(comboId);

            if (success) {
                response.sendRedirect("combo-management?success=delete");
            } else {
                response.sendRedirect("combo-management?error=delete");
            }
        } catch (Exception e) {
            response.sendRedirect("combo-management?error=delete");
        }
    }
}
