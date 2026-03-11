//function toggleDropdown(menuId){
//    let menu = document.getElementById(menuId);
//    menu.style.display = (menu.style.display === "block") ? "none" : "block";
//}

function selectOption(value,text,labelId,inputId,menuId){

    document.getElementById(labelId).innerText = text;

    document.getElementById(inputId).value = value;

    document.getElementById(menuId).style.display = "none";

    // SUBMIT FORM -> FILTER
    document.getElementById("searchForm").submit();
}

function selectDate(date){

    document.getElementById("selectedDateText").innerText = date;

    document.getElementById("dateInput").value = date;

    document.getElementById("dateMenu").style.display = "none";

    // SUBMIT FORM
    document.getElementById("searchForm").submit();
}

let currentDate = new Date();
let selectedDate = null;

function toggleDropdown(id){

    let menu = document.getElementById(id);

    menu.style.display =
        menu.style.display === "block" ? "none" : "block";

    renderCalendar();
}

function renderCalendar(){

    const monthNames=[
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    ];

    let month=currentDate.getMonth();
    let year=currentDate.getFullYear();

    document.querySelectorAll("#calendarMonth, #calendarMonth2")
        .forEach(e => e.innerText = monthNames[month]+" "+year);

    let firstDay=new Date(year,month,1).getDay();
    let daysInMonth=new Date(year,month+1,0).getDate();

    let datesHTML="";

    for(let i=0;i<firstDay;i++){
        datesHTML+="<div></div>";
    }

    for(let d=1;d<=daysInMonth;d++){

        datesHTML+=`
        <div onclick="pickDate(${d})">${d}</div>
        `;
    }

    document.querySelectorAll("#calendarDates, #calendarDates2")
        .forEach(e => e.innerHTML = datesHTML);
}

function pickDate(day){

    selectedDate=new Date(
        currentDate.getFullYear(),
        currentDate.getMonth(),
        day
    );

}

function changeMonth(step){

    currentDate.setMonth(currentDate.getMonth()+step);

    renderCalendar();
}

function selectToday(){

    selectedDate=new Date();

    applyDate();
}

function applyDate(){

    if(!selectedDate) return;

    let yyyy=selectedDate.getFullYear();
    let mm=String(selectedDate.getMonth()+1).padStart(2,'0');
    let dd=String(selectedDate.getDate()).padStart(2,'0');

    let date=yyyy+"-"+mm+"-"+dd;

    document.getElementById("selectedDateText").innerText=date;
    document.getElementById("dateInput").value=date;

    document.getElementById("calendarMenu").style.display="none";

    document.getElementById("searchForm").submit();
}

document.addEventListener("click", function(e){

    const dropdowns = document.querySelectorAll(".dropdown-custom .dropdown-menu, .calendar-menu");

    dropdowns.forEach(menu => {

        if(!menu.parentElement.contains(e.target)){
            menu.style.display = "none";
        }

    });

});

function selectOptionNoSubmit(value,text,labelId,inputId,menuId){

    document.getElementById(labelId).innerText = text;

    document.getElementById(inputId).value = value;

    document.getElementById(menuId).style.display = "none";

}


function applySwitchDate(){

    if(!selectedDate) return;

    let yyyy = selectedDate.getFullYear();
    let mm = String(selectedDate.getMonth()+1).padStart(2,'0');
    let dd = String(selectedDate.getDate()).padStart(2,'0');

    let date = yyyy+"-"+mm+"-"+dd;

    document.getElementById("selectedSwitchDateText").innerText = date;

    document.getElementById("switchDateInput").value = date;

    document.getElementById("switchCalendarMenu").style.display="none";
}

function applyFromDate(){

    if(!selectedDate) return;

    let yyyy = selectedDate.getFullYear();
    let mm = String(selectedDate.getMonth()+1).padStart(2,'0');
    let dd = String(selectedDate.getDate()).padStart(2,'0');

    let date = yyyy+"-"+mm+"-"+dd;

    document.getElementById("selectedFromDateText").innerText = date;
    document.getElementById("fromDateInput").value = date;

    document.getElementById("fromCalendarMenu").style.display="none";

    document.getElementById("searchForm").submit();
}

function applyToDate(){

    if(!selectedDate) return;

    let yyyy = selectedDate.getFullYear();
    let mm = String(selectedDate.getMonth()+1).padStart(2,'0');
    let dd = String(selectedDate.getDate()).padStart(2,'0');

    let date = yyyy+"-"+mm+"-"+dd;

    document.getElementById("selectedToDateText").innerText = date;
    document.getElementById("toDateInput").value = date;

    document.getElementById("toCalendarMenu").style.display="none";

    document.getElementById("searchForm").submit();
}