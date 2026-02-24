document.addEventListener("DOMContentLoaded", function () {

    const form = document.getElementById("searchForm");
    if (!form) return;

    let timeout = null;
    const inputs = form.querySelectorAll("input, select");

    inputs.forEach(input => {

        if (input.name === "fullName") {

            input.addEventListener("input", function () {

                clearTimeout(timeout);

                timeout = setTimeout(() => {
                    form.submit();
                }, 500);

            });

        } else {

            input.addEventListener("change", function () {
                form.submit();
            });

        }

    });

});