package com.example.datn_qlkh.service;

import com.example.datn_qlkh.entity.DiaChi;
import com.example.datn_qlkh.repository.DiaChiRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DiaChiServiceImpl implements DiaChiService {

    private final DiaChiRepository repo;

    public DiaChiServiceImpl(DiaChiRepository repo) {
        this.repo = repo;
    }

    @Override
    public List<DiaChi> getAllByUser(Long nguoiDungId) {
        return repo.findByNguoiDungIdOrderByNgayTaoDesc(nguoiDungId);
    }

    @Override
    public DiaChi getDefaultByUser(Long nguoiDungId) {
        return repo.findByNguoiDungIdAndMacDinhTrue(nguoiDungId);
    }

    @Override
    @Transactional
    public DiaChi saveOrUpdate(DiaChi diaChi) {
        // 🔹 Nếu là cập nhật
        if (diaChi.getId() != null) {
            DiaChi existing = repo.findById(diaChi.getId()).orElseThrow();

            existing.setHoTenNhan(diaChi.getHoTenNhan());
            existing.setSoDienThoai(diaChi.getSoDienThoai());
            existing.setDiaChi(diaChi.getDiaChi());
            existing.setTinhThanh(diaChi.getTinhThanh());
            existing.setQuanHuyen(diaChi.getQuanHuyen());

            // Không thay đổi cờ mặc định ở đây
            return repo.save(existing);
        }

        // 🔹 Nếu là thêm mới
        DiaChi existingDefault = repo.findByNguoiDungIdAndMacDinhTrue(diaChi.getNguoiDungId());
        if (existingDefault != null) {
            existingDefault.setMacDinh(false);
            repo.save(existingDefault);
        }

        diaChi.setMacDinh(true);
        return repo.save(diaChi);
    }

    @Override
    @Transactional
    public void delete(Long id, Long nguoiDungId) {
        repo.deleteById(id);

        // Nếu sau khi xóa mà không còn địa chỉ nào => không làm gì thêm
        List<DiaChi> remaining = repo.findByNguoiDungIdOrderByNgayTaoDesc(nguoiDungId);
        if (!remaining.isEmpty() && remaining.stream().noneMatch(DiaChi::getMacDinh)) {
            DiaChi newest = remaining.get(0);
            newest.setMacDinh(true);
            repo.save(newest);
        }
    }

    @Override
    @Transactional
    public void setDefault(Long id, Long nguoiDungId) {
        DiaChi existingDefault = repo.findByNguoiDungIdAndMacDinhTrue(nguoiDungId);
        if (existingDefault != null) {
            existingDefault.setMacDinh(false);
            repo.save(existingDefault);
        }

        DiaChi diaChi = repo.findById(id).orElseThrow();
        diaChi.setMacDinh(true);
        repo.save(diaChi);
    }
}
