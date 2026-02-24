function editRow(id) {

    let row = document.getElementById("row-" + id);
    let btn = document.getElementById("editBtn-" + id);

    let views = row.querySelectorAll(".view");
    let edits = row.querySelectorAll(".edit");

    if (btn.innerText === "Edit") {

        views.forEach(v => v.classList.add("d-none"));
        edits.forEach(e => e.classList.remove("d-none"));

        btn.innerText = "Save";
        btn.classList.remove("btn-success");
        btn.classList.add("btn-warning");

        let cancelBtn = document.createElement("button");
        cancelBtn.innerText = "Cancel";
        cancelBtn.className = "btn btn-danger btn-sm ms-1";
        cancelBtn.id = "cancel-" + id;

        cancelBtn.onclick = function () {

            views.forEach(v => v.classList.remove("d-none"));
            edits.forEach(e => e.classList.add("d-none"));

            btn.innerText = "Edit";
            btn.classList.remove("btn-warning");
            btn.classList.add("btn-success");

            cancelBtn.remove();
        };

        btn.after(cancelBtn);

    } else {

        let shiftId = document.getElementById("shift-" + id).value;
        let checkIn = document.getElementById("checkin-" + id).value;
        let checkOut = document.getElementById("checkout-" + id).value;

        fetch(contextPath + "/shift/manager/attendance/update", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                attendanceId: id,
                shiftId: shiftId,
                checkInTime: checkIn,
                checkOutTime: checkOut
            })
        })
        .then(() => location.reload());
    }
}

document.addEventListener("DOMContentLoaded", function () {

    const form = document.getElementById("searchForm");
    if (!form) return;

    let timeout = null;

    const inputs = form.querySelectorAll("input, select");

    inputs.forEach(input => {

        // Full Name → debounce 500ms
        if (input.name === "fullName") {

            input.addEventListener("input", function () {

                clearTimeout(timeout);

                timeout = setTimeout(() => {
                    form.submit();
                }, 500);

            });

        }
        // Shift & Status → submit ngay khi change
        else {
            input.addEventListener("change", function () {
                form.submit();
            });
        }
    });
});