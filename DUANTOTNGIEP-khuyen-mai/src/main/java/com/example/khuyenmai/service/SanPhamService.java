package com.example.khuyenmai.service;

import com.example.khuyenmai.entity.KhuyenMai;
import com.example.khuyenmai.entity.SanPham;
import com.example.khuyenmai.repository.SanPhamRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SanPhamService {
    private final SanPhamRepository repo;

    public SanPhamService(SanPhamRepository repo) {
        this.repo = repo;
    }

    public List<SanPham> getAll() {
        return repo.findAll();
    }

    public Optional<SanPham> findById(Long id) {
        return repo.findById(id);
    }

    public SanPham save(SanPham sp) {
        return repo.save(sp);
    }

    public void delete(Long id) {
        repo.deleteById(id);
    }

    public void apDungKhuyenMai(Long idSp, KhuyenMai km) {
        repo.findById(idSp).ifPresent(sp -> {
            sp.setKhuyenMai(km);
            repo.save(sp);
        });
    }

    public void huyKhuyenMai(Long idSp) {
        repo.findById(idSp).ifPresent(sp -> {
            sp.setKhuyenMai(null);
            repo.save(sp);
        });
    }
}
