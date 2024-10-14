<?php
// Connect to the database
$db = mysqli_connect('localhost', 'root', '', 'users');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Check connection
if (!$db) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit();
}

$id = isset($_POST['id']) ? $_POST['id'] : null;

if ($id === null) {
    echo json_encode(["status" => "error", "message" => "Error: Missing data"]);
    exit();
}

// Check if the record exists
$sql = "SELECT id FROM activity WHERE id = ?";
$stmt = mysqli_prepare($db, $sql);
mysqli_stmt_bind_param($stmt, 'i', $id);
mysqli_stmt_execute($stmt);
mysqli_stmt_store_result($stmt);

if (mysqli_stmt_num_rows($stmt) == 1) {
    // Prepare delete statement
    $delete = "DELETE FROM `activity` WHERE `id` = ?";
    $stmt = mysqli_prepare($db, $delete);
    mysqli_stmt_bind_param($stmt, 'i', $id);
    if (mysqli_stmt_execute($stmt)) {
        echo json_encode(["status" => "success", "message" => "Record deleted successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error deleting record"]);
    }
} else {
    // Record does not exist
    echo json_encode(["status" => "error", "message" => "Error: Record not found"]);
}

mysqli_stmt_close($stmt);
mysqli_close($db);
?>
