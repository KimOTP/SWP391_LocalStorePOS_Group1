<div class="main-content">
    <div class="d-flex justify-content-between mb-4">
        <h2>Supplier Management</h2>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSupplierModal">
            Add supplier
        </button>
    </div>

    <table class="table table-hover">
        <thead>
        <tr>
            <th>ID</th>
            <th>Supplier Name</th>
            <th>Contact</th>
            <th>Email</th>
            <th class="text-end">Action</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="s" items="${suppliers}">
            <tr>
                <td>#${s.supplierId}</td>
                <td class="fw-bold">${s.supplierName}</td>
                <td>${s.contactName}</td>
                <td>${s.email}</td>
                <td class="text-end">
                    <button class="btn btn-sm btn-light border"
                            data-id="${s.supplierId}"
                            data-name="${s.supplierName}"
                            data-contact="${s.contactName}"
                            data-email="${s.email}"
                            onclick="openEditModal(this)">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </button>
                    <button class="btn btn-sm btn-light border text-danger" onclick="confirmDelete(${s.supplierId})">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>

<div class="modal fade" id="addSupplierModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="/admin/suppliers/add" method="post">
                <div class="modal-header"><h5>Add New Supplier</h5></div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Supplier Name</label>
                        <input type="text" name="supplierName" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editSupplierModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="/admin/suppliers/update" method="post">
                <div class="modal-header bg-light"><h5>Update Supplier Information</h5></div>
                <div class="modal-body">
                    <input type="hidden" name="supplierId" id="editSupplierId">

                    <div class="mb-3">
                        <label class="form-label">Supplier Name</label>
                        <input type="text" name="supplierName" id="editSupplierName" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Contact Name</label>
                        <input type="text" name="contactName" id="editContactName" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" id="editEmail" class="form-control">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="<c:url value='/resources/js/supplier.js'/>"></script>