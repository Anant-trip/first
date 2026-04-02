<%@page import="com.tyss.entity.Student"%>
<%@page import="com.tyss.entity.Course"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Course List</title>

<style>
body {
	margin: 0;
	font-family: Arial, sans-serif;
	background-color: #f4f6f9;
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
}

.header .icons {
	display: flex;
	gap: 20px;
	font-size: 18px;
}

.breadcrumb {
	padding: 15px 25px;
	font-size: 14px;
}

.breadcrumb a {
	text-decoration: none;
	color: #2c4a7a;
	font-weight: bold;
}

.container {
	margin: 20px;
	background: white;
	padding: 20px;
	border-radius: 6px;
	box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

table {
	width: 100%;
	border-collapse: collapse;
}

th {
	background-color: #e9edf2;
	padding: 12px;
	text-align: left;
	font-size: 14px;
}

td {
	padding: 12px;
	border-top: 1px solid #ddd;
	font-size: 14px;
}

tr:hover {
	background-color: #f9fbfd;
}

.btn-edit {
	background-color: #2c6ed5;
	color: white;
	padding: 6px 12px;
	border: none;
	border-radius: 4px;
	cursor: pointer;
	font-size: 13px;
}

.btn-edit:hover {
	background-color: #1f57a8;
}
</style>

</head>
<body>


	<div class="header">
		<h2>Course List</h2>
		<div class="icons">🌐 ✉️ 👤</div>
	</div>


	<div class="breadcrumb">
		<a href="dashboard">Home</a> / Courses
	</div>

	<%
	List<Course> courses = (List<Course>) request.getAttribute("courses");
	%>

	<div class="container">
		<table>
			<thead>
				<tr>
					<th>ID</th>
					<th>Course Name</th>
					<th>Duration</th>
					<th>Students Enrolled</th>
					<th>Action</th>
				</tr>
			</thead>
			<tbody>

			<%
				if(!courses.isEmpty())
				{
					for(Course c : courses)
					{
			%>

				<tr>
					<td><%=c.getId()%></td>
					<td><%=c.getName() %></td>
					<td><%=c.getDuration() %></td>
					<td>
					<%
						for(Student s : c.getStudents())
						{
					%>	
						<%=s.getName() %>
					<%
						}
					%>
					</td>
					<td>
						<a href="edit-course?cid=<%= c.getId() %>" class="btn-edit">Edit</a>
						<a href="delete-course?cid=<%= c.getId() %>" class="btn-edit">Delete</a>
					</td>
				</tr>
				<%
					}
				}else{
				%>
				<tr><td style="color: red">Courses not found!!!!!!</td></tr>
				<%
				} 
				%>
			</tbody>
		</table>
	</div>

</body>
</html>