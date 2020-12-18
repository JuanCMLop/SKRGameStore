<%@page import="dao.UserDao"%>
<%@page import="beans.User"%>
<%@page import="common.*"%>


<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_HOME);

    User user = null;
    String errmsg = "";
    String repassword = "";

    if (helper.isLoggedin()) {
        errmsg = "Porfavor cierre sesión!";
    } else {
        String usertype = Constants.CONST_TYPE_CUSTOMER;
        if ("GET".equalsIgnoreCase(request.getMethod())) {

        } else {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            repassword = request.getParameter("repassword");
            if (!helper.isLoggedin()) {
                usertype = request.getParameter("usertype");
            }
            user = new User(username, password, usertype);
            if (!password.equals(repassword)) {
                    errmsg = "Las contraseñas no coinciden!";
            } else {
                UserDao dao = UserDao.createInstance();
                if (dao.isExisted(username)) {
                    errmsg = "El usuario [" + user.getName() + "] ya existe, intenta con otro nombre";
                } else {
                    dao.addUser(user);
                    session.setAttribute(Constants.SESSION_LOGIN_MSG, "El tipo de usuario" + usertype + " creado, Loguearse!");
                    if (!helper.isLoggedin()) {
                        response.sendRedirect("account_login.jsp");
                        return;
                    } else {
                        response.sendRedirect("index.jsp");
                        return;
                    }
                }
            }
        }
    }
    request.setAttribute("errmsg", errmsg);
    request.setAttribute("repassword", repassword);
    request.setAttribute("user", user);
%>
<jsp:include page="layout_menu.jsp" />
<section id="content">
    <div class="post">    
        <h3 style='color:red'>${errmsg}</h3>    
        <form action="account_register.jsp" method="Post">
            <table style='width:50%'>
                <tr><td><h5>Usuario:</h5></td><td><input type='text' name='username' value='${user.name}' class='input' required /></td></tr>
                <tr><td><h5>Pass:</h5></td><td><input type='password' name='password' value='${user.password}' class='input' required /></td></tr>
                <tr><td><h5>Re-Pass:</h5></td><td><input type='password' name='repassword' value='${repassword}' class='input' required /></td></tr>
                <tr><td><h5>Tipo de Usuario</h5></td><td><select name='usertype' class='input'><option value='customer' selected>Customer</option><option value='storemanager'>StoreManager</option><option value='salesman'>Salesman</option></select></td></tr>
                <tr><td colspan="2"><input name="register" class="formbutton" value="Registrar" type="submit" /></td></tr>
            </table>
        </form>
    </div>
</section>
<jsp:include page="layout_footer.jsp" />