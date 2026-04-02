<%@page import="com.tyss.entity.Course"%>
<%@page import="com.tyss.entity.Student"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Student List</title>

<style>
* {
	box-sizing: border-box;
}

body {
	margin: 0;
	font-family: Arial, sans-serif;
	background-color: #f4f6f9;
	color: #333;
}

.header {
	background-color: #2c4a7a;
	color: white;
	padding: 15px 25px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.header h2 {
	margin: 0;
	font-size: 26px;
	font-weight: bold;
}

.header .icons {
	display: flex;
	gap: 18px;
	font-size: 18px;
	align-items: center;
}

.breadcrumb {
	padding: 15px 25px;
	font-size: 14px;
	color: #666;
}

.breadcrumb a {
	text-decoration: none;
	color: #2c4a7a;
	font-weight: bold;
}

.page-wrapper {
	padding: 0 20px 20px 20px;
}

.container {
	background: white;
	padding: 20px;
	border-radius: 8px;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
	overflow-x: auto;
}

table {
	width: 100%;
	border-collapse: collapse;
	background-color: white;
}

th {
	background-color: #eef2f7;
	color: #2f3b52;
	padding: 14px 12px;
	text-align: left;
	font-size: 14px;
	font-weight: 600;
	border-bottom: 1px solid #dcdfe5;
}

td {
	padding: 14px 12px;
	font-size: 14px;
	border-bottom: 1px solid #e5e7eb;
	vertical-align: middle;
}

tr:hover {
	background-color: #f9fbfd;
}

.action-buttons {
	display: flex;
	gap: 8px;
	flex-wrap: wrap;
}

.btn {
	text-decoration: none;
	padding: 8px 14px;
	border-radius: 4px;
	font-size: 13px;
	font-weight: 500;
	display: inline-block;
	color: white;
}

.btn-edit {
	background-color: #2c6ed5;
}

.btn-edit:hover {
	background-color: #1f57a8;
}

.btn-delete {
	background-color: #dc3545;
}

.btn-delete:hover {
	background-color: #b52a37;
}

.student-name {
	font-weight: 600;
	color: #1f2d3d;
}

.status {
	display: inline-block;
	padding: 5px 10px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 600;
	background-color: #e6f4ea;
	color: #1e7e34;
}

@media screen and (max-width: 768px) {
	.header {
		flex-direction: column;
		align-items: flex-start;
		gap: 10px;
	}

	.header h2 {
		font-size: 22px;
	}

	th, td {
		font-size: 13px;
		padding: 10px 8px;
	}

	.btn {
		padding: 6px 10px;
		font-size: 12px;
	}
}
</style>
</head>
<body>

<%
	List<Student> stds = (List<Student>) request.getAttribute("students");
%>

	<div class="header">
		<h2>Student List</h2>
		<div class="icons">🌐 ✉️ 👤</div>
	</div>

	<div class="breadcrumb">
		<a href="dashboard">Home</a> / Students
	</div>

	<div class="page-wrapper">
		<div class="container">
			<table>
				<thead>
					<tr>
						<th>ID</th>
						<th>Student Name</th>
						<th>Email</th>
						<th>Course Name</th>
						<th>Action</th>
					</tr>
				</thead>
				<tbody>
					
					<%
						if(!stds.isEmpty())
						{
							for(Student s : stds)
							{
					%>
					<tr>
						<td><%=s.getId() %></td>
						<td class="student-name"><%=s.getName()%></td>
						<td><%=s.getEmail()%></td>
						<td>
							<%
								for(Course c : s.getCourses())
								{
							%>
									<%=c.getName()%> ,
							<%
								}
							%>
						</td>
						<td>
							<div class="action-buttons">
								<a href="#" class="btn btn-edit">Edit</a>
								<a href="#" class="btn btn-delete">Delete</a>
							</div>
						</td>
					</tr>
					<%
							}
						}
					%>

				</tbody>
			</table>
		</div>
	</div>

</body>
</html>