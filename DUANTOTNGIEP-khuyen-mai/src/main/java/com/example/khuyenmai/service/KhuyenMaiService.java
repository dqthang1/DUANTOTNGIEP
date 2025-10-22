package com.example.khuyenmai.service;

import com.example.khuyenmai.entity.KhuyenMai;
import com.example.khuyenmai.repository.KhuyenMaiRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class KhuyenMaiService {
    private final KhuyenMaiRepository repo;

    public KhuyenMaiService(KhuyenMaiRepository repo) {
        this.repo = repo;
    }

    public List<KhuyenMai> getAll() {
        return repo.findAll();
    }

    public KhuyenMai save(KhuyenMai km) {
        return repo.save(km);
    }

    public void delete(Long id) {
        repo.deleteById(id);
    }

    public Optional<KhuyenMai> findById(Long id) {
        return repo.findById(id);
    }

    public List<KhuyenMai> search(String ten) {
        return repo.findByTenContainingIgnoreCase(ten);
    }
}
