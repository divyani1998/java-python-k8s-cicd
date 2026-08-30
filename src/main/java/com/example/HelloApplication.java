package com.example;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

/**
 * Minimal Java HTTP application.
 * Returns a simple Hello World response.
 */
public class HelloApplication {

    public static void main(String[] args) throws IOException {

        int port = 8080;

        HttpServer server = HttpServer.create(
                new InetSocketAddress(port), 0);

        server.createContext("/", HelloApplication::handleRequest);

        server.start();

        System.out.println("Application started on port " + port);
    }

    private static void handleRequest(HttpExchange exchange)
            throws IOException {

        String response = "Hello World from Java + Kubernetes!";

        exchange.sendResponseHeaders(200, response.length());

        try (OutputStream outputStream = exchange.getResponseBody()) {
            outputStream.write(response.getBytes());
        }
    }
}
