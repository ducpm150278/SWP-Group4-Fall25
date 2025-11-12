package com.cinema.controller.food;

/**
 *
 * @author minhd
 */

import com.cinema.dal.ComboDAO;
import com.cinema.dal.ComboFoodDAO;
import com.cinema.dal.FoodDAO;
import com.cinema.entity.Combo;
import com.cinema.entity.Food;
import com.cinema.utils.Constants;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Map;

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
        } else if ("getComboFoods".equals(action)) {
            getComboFoods(request, response); // THÊM DÒNG NÀY
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
        request.getRequestDispatcher(Constants.JSP_FOOD_COMBO).forward(request, response);
    }

    private void getComboById(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int comboId = Integer.parseInt(request.getParameter("id"));
            Combo combo = comboDAO.getComboById(comboId);

            if (combo != null) {
                request.setAttribute("combo", combo);
                request.getRequestDispatcher(Constants.JSP_FOOD_EDIT_COMBO).forward(request, response);
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
            request.getRequestDispatcher(Constants.JSP_FOOD_ADD_COMBO).forward(request, response);
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

    private void getComboFoods(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String comboIdParam = request.getParameter("comboId");
            System.out.println("Getting combo foods for comboId: " + comboIdParam);

            if (comboIdParam == null || comboIdParam.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Combo ID is required\"}");
                return;
            }

            int comboId = Integer.parseInt(comboIdParam);

            ComboFoodDAO comboFoodDAO = new ComboFoodDAO();
            List<Map<String, Object>> foodItems = comboFoodDAO.getComboFoodItemsWithQuantity(comboId);

            // DEBUG: In ra toàn bộ dữ liệu
            System.out.println("=== DEBUG FOOD ITEMS ===");
            if (foodItems != null) {
                for (Map<String, Object> item : foodItems) {
                    System.out.println("Food Item: " + item);
                    for (Map.Entry<String, Object> entry : item.entrySet()) {
                        System.out.println("  " + entry.getKey() + ": " + entry.getValue() + " (type: " + (entry.getValue() != null ? entry.getValue().getClass().getSimpleName() : "null") + ")");
                    }
                }
            } else {
                System.out.println("foodItems is null");
            }
            System.out.println("=== END DEBUG ===");

            // Convert to JSON manually
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            String jsonResponse = convertToJson(foodItems);

            System.out.println("Sending JSON response: " + jsonResponse);
            response.getWriter().write(jsonResponse);

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid combo ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error loading food items: " + e.getMessage() + "\"}");
        }
    }

// Helper method to convert List<Map> to JSON manually
    private String convertToJson(List<Map<String, Object>> foodItems) {
        if (foodItems == null || foodItems.isEmpty()) {
            return "[]";
        }

        StringBuilder jsonBuilder = new StringBuilder();
        jsonBuilder.append("[");

        for (int i = 0; i < foodItems.size(); i++) {
            Map<String, Object> food = foodItems.get(i);
            jsonBuilder.append("{");

            boolean firstEntry = true;
            for (Map.Entry<String, Object> entry : food.entrySet()) {
                if (!firstEntry) {
                    jsonBuilder.append(",");
                }

                jsonBuilder.append("\"").append(entry.getKey()).append("\":");

                Object value = entry.getValue();
                if (value instanceof String) {
                    String stringValue = (String) value;
                    // Kiểm tra nếu giá trị null trong database
                    if ("null".equalsIgnoreCase(stringValue) || stringValue == null) {
                        jsonBuilder.append("null");
                    } else {
                        String escapedValue = escapeJsonString(stringValue);
                        jsonBuilder.append("\"").append(escapedValue).append("\"");
                    }
                } else if (value instanceof Number) {
                    jsonBuilder.append(value);
                } else if (value instanceof Boolean) {
                    jsonBuilder.append(value);
                } else if (value == null) {
                    jsonBuilder.append("null");
                } else {
                    // For BigDecimal and other types
                    String stringValue = value.toString();
                    // Kiểm tra nếu là số
                    if (stringValue.matches("-?\\d+(\\.\\d+)?")) {
                        jsonBuilder.append(stringValue);
                    } else {
                        jsonBuilder.append("\"").append(escapeJsonString(stringValue)).append("\"");
                    }
                }

                firstEntry = false;
            }

            jsonBuilder.append("}");

            if (i < foodItems.size() - 1) {
                jsonBuilder.append(",");
            }
        }

        jsonBuilder.append("]");
        return jsonBuilder.toString();
    }

// Helper method to escape JSON string
    private String escapeJsonString(String input) {
        if (input == null) {
            return "";
        }

        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
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
