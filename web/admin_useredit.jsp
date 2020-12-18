<%@page import="java.util.*"%>
<%@page import="beans.*"%>
<%@page import="common.*"%>
<%@page import="dao.UserDao"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_USERMNG);
    if (!helper.isLoggedin()) {
        session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor iniciar sesión!");
        response.sendRedirect("account_login.jsp");
        return;
    }
    String usertype = helper.usertype();
    String errmsg = "";
    if (usertype == null || !usertype.equals(Constants.CONST_TYPE_SALESMAN_LOWER)) {
        errmsg = "No tienes autorización para gestionar usuarios!";
    }

    String name = request.getParameter("name");
    if (name == null || name.isEmpty()) {
        errmsg = "Parámetros no válidos!";
    }

    User user = null;
    if (errmsg.isEmpty()) {
        UserDao dao = UserDao.createInstance();
        user = dao.getUser(name);
        if (user == null) {
            errmsg = "El usuario [" + name + "] no existe!";
        } else {
            if ("GET".equalsIgnoreCase(request.getMethod())) {

            } else {
                String password = request.getParameter("password");
                if (password == null || password.isEmpty()) {
                    errmsg = "La contraseña no puede estar vacía!";
                }
                if (errmsg.isEmpty()) {
                    user.setPassword(password);
                    errmsg = "El usuario [" + name + "] está actualizado!";
                }
            }
        }
    }
    pageContext.setAttribute("errmsg", errmsg);
    pageContext.setAttribute("list", helper.getUserTypeList());
    pageContext.setAttribute("user", user);
%>
<jsp:include page="layout_menu.jsp" />
<section id="content">
    <div>
        <h3>Editar Usuario</h3>
        <h3 style='color:red'>${errmsg}</h3>
        <form action="admin_useredit.jsp" method="Post">
            <input type='hidden' name='usertype' value='${user.usertype}'>
            <input type='hidden' name='name' value='${user.name}'>
            <table style='width:50%'>
                <tr><td><h5>User Type:</h5></td>
                    <td>
                        <select name='usertype' class='input' disabled>
                            <c:forEach var="option" items="${list}">
                                <c:choose>
                                    <c:when test="${option.key == user.usertype.toLowerCase()}">
                                        <option value=${option.key} selected>${option.text}</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value=${option.key}>${option.text}</option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>  
                        </select>
                    </td>
                </tr>
                <tr><td><h5>Nombres:</h5></td><td><input type='text' name='name' value='${user.name}' class='input' required disabled/></td></tr>
                <tr><td><h5>Pass:</h5></td><td><input type='text' name='password' value='${user.password}' class='input' required /></td></tr>
                <tr><td colspan="2"><input name="create" class="formbutton" value="Guardar" type="submit" /></td></tr>
            </table>
        </form>
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />