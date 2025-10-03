/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

$(document).ready(function () {
    $(".quick-view-btn").click(function () {
        var productID = $(this).data("id"); // Get product ID
        $.ajax({
            url: "QuickView", // Send request to servlet
            type: "GET",
            data: {productID: productID},
            dataType: "json",
            success: function (data) {
                // Update modal with product data
                $("#quickViewModal .modal_tab_img img").attr("src", contextPath + data.imageURL);
                $("#quickViewModal h3").text(data.name);
                $("#quickViewModal p").text(data.description);
                $("#quickViewModal .pricing span").html(
                    "$" + (data.price * (1 - data.discount / 100)).toFixed(2) + 
                    " <del>$" + data.price.toFixed(2) + "</del>"
                );
                $("#quickViewModal .cate span.category-name").text(data.category);

                // Update rating
                let ratingHTML = "";
                let roundedRating = Math.round(data.rating * 2) / 2;
                for (let i = 1; i <= 5; i++) {
                    if (i <= roundedRating) {
                        ratingHTML += '<i class="fas fa-star"></i>'; // Full star
                    } else {
                        ratingHTML += '<i class="far fa-star"></i>'; // Empty star
                    }
                }
                $("#quickViewModal .ratting").html(ratingHTML); // Insert into modal

                // Store productID in the Add To Cart button inside the modal
                $("#quickViewModal .cart-btn a").data("id", data.productID);
            },
            error: function () {
                alert("Unable to fetch product data!");
            }
        });
    });

    // Handle Add to Cart click event in Quick View
    $("#quickViewModal").on("click", ".cart-btn a", function (e) {
        e.preventDefault();
        var productID = $(this).data("id"); // Get product ID
        var quantity = $("#quickViewModal .quantity input").val(); // Get quantity

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
