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

// Retrieve POST data and validate
$id = isset($_POST['id']) ? $_POST['id'] : null;
$title = isset($_POST['title']) ? $_POST['title'] : null;
$description = isset($_POST['description']) ? $_POST['description'] : null;
$imagePath = isset($_POST['imagePath']) ? $_POST['imagePath'] : "https://www.shutterstock.com/image-vector/slogan-oops-sorry-funny-vector-260nw-1514682761.jpg";
$scoreType = isset($_POST['scoreType']) ? $_POST['scoreType'] : null;
$score = isset($_POST['score']) ? $_POST['score'] : null;
$isJoinable = isset($_POST['isJoinable']) ? $_POST['isJoinable'] : true;
$datetime = isset($_POST['datetime']) ? $_POST['datetime'] : "";
$location = isset($_POST['location']) ? $_POST['location'] : "";

// Array to hold missing fields
$missingFields = [];

if ($id === null) $missingFields[] = "id";
if ($title === null) $missingFields[] = "title";
if ($description === null) $missingFields[] = "description";
if ($scoreType === null) $missingFields[] = "scoreType";
if ($score === null) $missingFields[] = "score";
if ($datetime === "") $missingFields[] = "datetime";
if ($location === "") $missingFields[] = "location";

if (!empty($missingFields)) {
    echo json_encode([
        "status" => "error",
        "message" => "Error: Missing data",
        "missing_fields" => $missingFields
    ]);
    exit();
}

// Check if the record exists
$sql = "SELECT id FROM activity WHERE id = ?";
$stmt = mysqli_prepare($db, $sql);
mysqli_stmt_bind_param($stmt, 'i', $id);
mysqli_stmt_execute($stmt);
mysqli_stmt_store_result($stmt);

if (mysqli_stmt_num_rows($stmt) == 1) {
    // Record exists, update it
    $update = "UPDATE activity SET title = ?, description = ?, imagePath = ?, scoreType = ?, score = ?, isJoinable = ?, event_dateTime = ?, location = ? WHERE id = ?";
    $stmt = mysqli_prepare($db, $update);
    mysqli_stmt_bind_param($stmt, 'ssssibssi', $title, $description, $imagePath, $scoreType, $score, $isJoinable, $datetime, $location, $id);
    if (mysqli_stmt_execute($stmt)) {
        echo json_encode(["status" => "success", "message" => "Record updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error updating record"]);
    }
} else {
    // Record does not exist, insert it
    $insert = "INSERT INTO activity (id, title, description, scoreType, score, imagePath, isJoinable, event_dateTime, location) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = mysqli_prepare($db, $insert);
    mysqli_stmt_bind_param($stmt, 'issssibss', $id, $title, $description, $scoreType, $score, $imagePath, $isJoinable, $datetime, $location);
    if (mysqli_stmt_execute($stmt)) {
        echo json_encode(["status" => "success", "message" => "Record added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error adding record"]);
    }
}

// Close statement and connection
mysqli_stmt_close($stmt);
mysqli_close($db);
?>
