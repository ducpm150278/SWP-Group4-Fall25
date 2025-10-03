/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

$(document).ready(function () {
    $(".add-to-cart-btn").click(function (e) {
        e.preventDefault();
        var productID = $(this).data("id");
        var quantity = 1;

        $.ajax({
            url: "AddToCart",
            type: "POST",
            data: {productID: productID, quantity: quantity},
            dataType: "json",
            success: function (response) {
                if (response.status === "success") {
                    Swal.fire({
                        title: "Success!",
                        text: "The product has been added to your cart.",
                        icon: "success",
                        showCancelButton: true,
                        confirmButtonText: "View Cart",
                        cancelButtonText: "Continue Shopping",
                        timer: 3000
                    }).then((result) => {
                        if (result.isConfirmed) {
                            window.location.href = "cart.jsp";
                        } else {
                            location.reload(); // Reload the page if the user continues shopping
                        }
                    });
                } else {
                    Swal.fire({
                        title: "Error!",
                        text: "Failed to add to cart!",
                        icon: "error",
                        confirmButtonText: "OK"
                    });
                }
            },
            error: function () {
                Swal.fire({
                    title: "Connection Error!",
                    text: "Please try again later.",
                    icon: "warning",
                    confirmButtonText: "OK"
                });
            }
        });
    });
});
