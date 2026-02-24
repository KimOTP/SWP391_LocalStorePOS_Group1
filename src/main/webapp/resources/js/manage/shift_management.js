function editRow(id) {

    let row = document.getElementById("row-" + id);
    let button = row.querySelector(".edit-btn");

    if (button.innerText.trim() === "Edit") {

        row.querySelectorAll(".view").forEach(e => e.classList.add("d-none"));
        row.querySelectorAll(".edit").forEach(e => e.classList.remove("d-none"));

        button.innerText = "Save";

    } else {

        let inputs = row.querySelectorAll(".edit");
        let name = inputs[0].value;
        let start = inputs[1].value;
        let end = inputs[2].value;

        // Validate đơn giản
        if (!name || !start || !end) {
            alert("Please fill all fields");
            return;
        }

        if (end <= start) {
            alert("End time must be after start time");
            return;
        }

        fetch(contextPath + "/shift/update", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: `id=${id}&name=${name}&start=${start}&end=${end}`
        })
        .then(res => res.text())
        .then(data => {

            if (data === "success") {

                row.querySelectorAll(".view")[0].innerText = name;
                row.querySelectorAll(".view")[1].innerText = start;
                row.querySelectorAll(".view")[2].innerText = end;

                let durationCell = row.querySelector(".duration");

                let startTime = new Date("1970-01-01T" + start);
                let endTime = new Date("1970-01-01T" + end);

                let diff = (endTime - startTime) / (1000 * 60 * 60);
                durationCell.innerText = diff + "h";

                row.querySelectorAll(".view").forEach(e => e.classList.remove("d-none"));
                row.querySelectorAll(".edit").forEach(e => e.classList.add("d-none"));

                button.innerText = "Edit";

            } else {
                alert("Update failed!");
            }
        });
    }
}