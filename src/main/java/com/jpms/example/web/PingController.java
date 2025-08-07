package com.jpms.example.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class PingController {

    @GetMapping("/ping")
    public Map<String, Object> ping() {
        Map<String, Object> res = new LinkedHashMap<>();
        res.put("status", "ok");

        try {
            MemoryMXBean memBean = ManagementFactory.getMemoryMXBean();
            MemoryUsage heap = memBean.getHeapMemoryUsage();
            MemoryUsage nonHeap = memBean.getNonHeapMemoryUsage();

            Map<String, Object> mem = new LinkedHashMap<>();
            mem.put("heapUsed", heap.getUsed());
            mem.put("heapCommitted", heap.getCommitted());
            mem.put("heapMax", heap.getMax());
            mem.put("nonHeapUsed", nonHeap.getUsed());
            mem.put("nonHeapCommitted", nonHeap.getCommitted());

            res.put("memory", mem);
        } catch (Throwable ignored) {
            // keep resilient
        }

        return res;
    }
}