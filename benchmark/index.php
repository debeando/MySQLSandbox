<!DOCTYPE html>
<html>
<head>
<style>
html *
{
  font-family: "Lucida Console", "Lucida Sans Typewriter", monaco, "Bitstream Vera Sans Mono", monospace;
  font-size: 12px;
  font-style: normal;
  font-variant: normal;
  font-size: 1em !important;
  color: #000;
}
</style>
</head>
<body>
<?php
$host       = "172.20.1.201";
$username   = "sandbox";
$password   = "sandbox";
$dbname     = "sandbox";

function connect() {
  global $host, $username, $password, $dbname;

  $conn = new mysqli($host, $username, $password, $dbname);
  if ($conn->connect_error) {
    echo "==> Failed to connect to MySQL: (" . $conn->connect_errno . ") " . $conn->connect_error;
  }

  return $conn;
}

function close($conn) {
  $conn->close();
}

function info($conn) {
  $query  = "SELECT @@hostname AS host";
  $result = $conn->query($query);
  $rows   = mysqli_fetch_assoc($result);

  return $rows['host'];
}

function select($conn, $id, $host = NULL, $notify = false, $comment = NULL) {
  $query  = "SELECT value FROM test WHERE id = ${id}";
  $result = $conn->query($query);
  $rows   = mysqli_fetch_assoc($result);
  $value  = $rows['value'];

  if (is_null($value)) {
    $value = "<text style='color:#A52A2A'>empty</text>";

    if ($notify) {
      header($_SERVER["SERVER_PROTOCOL"]." 404 Not Found");
    }
  }

  if (isset($comment)) {
    $comment = " (${comment})";
  }

  echo "--> ${host} - Last inserted row value: $value$comment</br>\n";

  return $value;
}

function insert($conn, $host) {
  $query  = "INSERT INTO test (token, value, unixtimestamp) VALUES (UUID(),RAND(),UNIX_TIMESTAMP())";
  $result = $conn->query($query);
  $id     = mysqli_insert_id($conn);

  echo "--> ${host} - Last inserted row id: ${id}</br>\n";

  return $id;
}

function t1() {
  echo "<b>==> Test 1</b></br>\n";
  $conn = connect();
  $host = info($conn);
  $id = insert($conn, $host);
  select($conn, $id, $host);
  close($conn);
}

function t2() {
  echo "<b>==> Test 2</b></br>";
  $conn = connect();
  $host = info($conn);
  $conn->begin_transaction();
  $id = insert($conn, $host);
  select($conn, $id, $host);
  $conn->commit();
  close($conn);
}

function t3() {
  echo "<b>==> Test 3</b></br>";
  $conn1 = connect();
  $conn2 = connect();
  $host1 = info($conn1);
  $host2 = info($conn2);

  $conn1->begin_transaction();
  $id = insert($conn1, $host1);
  select($conn1, $id, $host1, false, 'In tx-1');
  select($conn2, $id, $host2, false, 'Another tx-2');
  $conn1->commit();
  select($conn2, $id, $host2, true, 'Execute tx-2 after tx-1');

  close($conn1);
  close($conn2);
}

t1();
t2();
t3();

?>
</body>
</html>
