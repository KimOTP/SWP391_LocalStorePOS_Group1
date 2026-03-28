document.addEventListener("DOMContentLoaded", function () {

    const form = document.getElementById("searchForm");
    if (!form) return;

    let timeout = null;

    const inputs = form.querySelectorAll("input, select");

    inputs.forEach(input => {

        // Employee ID dùng debounce
        if (input.name === "employeeId") {

            input.addEventListener("input", function () {

                clearTimeout(timeout);

                timeout = setTimeout(() => {
                    form.submit();
                }, 500);

            });

        }
        // Các select submit ngay
        else {

            input.addEventListener("change", function () {
                form.submit();
            });

        }

    });

});