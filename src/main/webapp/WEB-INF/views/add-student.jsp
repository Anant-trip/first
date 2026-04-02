<%@page import="com.tyss.entity.Course"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Student</title>
    <style>
        body {
            font-family: Arial;
            background: #eef2f7;
        }

        .modal {
            width: 450px;
            margin: 80px auto;
            background: white;
            border-radius: 6px;
            box-shadow: 0px 4px 12px rgba(0,0,0,0.2);
        }

        .modal-header {
            background: #2c4a7a;
            color: white;
            padding: 15px;
            font-size: 18px;
            display: flex;
            justify-content: space-between;
        }

        .modal-body {
            padding: 20px;
        }

        label {
            font-weight: bold;
        }

        input[type="text"], input[type="email"] {
            width: 100%;
            padding: 10px;
            margin: 10px 0 20px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        .checkbox-group label {
            display: block;
            margin: 5px 0;
        }

        .btn {
            width: 100%;
            padding: 12px;
            background: #2b6cb0;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
        }
    </style>
</head>

<body>

<div class="modal">
    <div class="modal-header">
        Add New Student
        <span>✖</span>
    </div>
<%
		List<Course> courses =(List<Course>) request.getAttribute("courses");
%>
    <div class="modal-body">
        <form action="add-student" method="post">

            <label>Name:</label>
            <input type="text" name="name" placeholder="Enter name" required>

            <label>Email:</label>
            <input type="email" name="email" placeholder="Enter email" required>

            <label>Select Courses:</label>
            <div class="checkbox-group">
            	<%
            		for(Course c : courses){
            	%>
                <label><input name="courseIds" value="<%= c.getId() %>" type="checkbox"><%=c.getName()%></label>
                <%
            		}
                %>
            </div>

            <button class="btn">Save Student</button>

        </form>
    </div>
</div>

</body>
</html>