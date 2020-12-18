<%@page import="common.*"%>
<%@page import="beans.*"%>
<%@page import="java.util.*"%>
<%@page import="dao.ProductDao"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String errmsg = "";
    List<SelectorOption> list = null;
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_ALLORDERS);
    if (!helper.isLoggedin()) {
        errmsg = "Porfavor inciar sesión!";
    } else {
        String usertype = helper.usertype();

        if (usertype == null || !usertype.equals(Constants.CONST_TYPE_SALESMAN_LOWER)) {
            errmsg = "No tienes autorización para gestionar el pedido!";
        }

        ProductDao dao = ProductDao.createInstance();
        List<ProductItem> products = dao.getProductList();
        list = new ArrayList<SelectorOption>();
        for (ProductItem product : products) {
            list.add(new SelectorOption(product.getId(), product.getName()));
        }
    }

    if ("GET".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String address = request.getParameter("address");
        String creditcard = request.getParameter("creditcard");
        Order order;
        synchronized (session) {
            order = (Order) session.getAttribute(Constants.SESSION_ORDERITEM);
            order.setUserName(username);
            order.setAddress(address);
            order.setCreditCard(creditcard);
        }
    } else {
        String productkey = request.getParameter("productkey");
        String strQuantity = request.getParameter("quantity");
        int quantity;
        try {
            quantity = Integer.parseInt(strQuantity);
        } catch (NumberFormatException nfe) {
            quantity = 1;
        }
        ProductDao dao = ProductDao.createInstance();
        ProductItem product = dao.getProduct(productkey);

        Order order;
        synchronized (session) {
            order = (Order) session.getAttribute(Constants.SESSION_ORDERITEM);
            if (order != null) {
                OrderItem item = new OrderItem(order.getItems().size() + 1, 0, product.getId(), product.getName(), product.getType(), product.getPrice(), product.getImage(), product.getMaker(), product.getDiscount(), 1);
                item.setQuantity(quantity);
                order.addItem(item);
                errmsg = "El producto se ha añadido al pedido!";
            }
        }
    }

    pageContext.setAttribute("errmsg", errmsg);
    pageContext.setAttribute("list", list);
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Add Item</title>
        <script src="//code.jquery.com/jquery-1.10.2.js"></script>
        <script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>  
        <link rel="stylesheet" 
              href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
        <!-- User defined css -->  
        <link rel="stylesheet" href="css/style.css" type="text/css" />
        <link rel="stylesheet" href="css/jquery.fancybox.css" type="text/css" />
        <script src="scripts/autocompleter.js"></script>
        <script src="scripts/jquery.fancybox.js"></script>
    </head>
    <body>
        <h1>Elige tu Producto</h1>
        <c:choose>
            <c:when test="${not empty errmsg}">
                <h3 style='color:red'>${errmsg}</h3>
            </c:when>
            <c:otherwise>
                <form action="admin_orderitemadd.jsp" method="Post">
                    <table>
                        <tr><td>Producto:</td>
                            <td>
                                <select name='productkey' class='input'>
                                    <c:forEach var="option" items="${list}">
                                        <option value=${option.key}>${option.text}</option>
                                    </c:forEach>  
                                </select>
                            </td>
                        </tr>
                        <tr><td>Cantidad:</td><td><input type='text' name='quantity' value='1' class='input' required /></td></tr>
                        <tr><td colspan="2"><input name="create" class="formbutton" value="Añadir" type="submit" /></td></tr>
                    </table>
                </form>
            </c:otherwise>
        </c:choose>
    </body>
</html>
