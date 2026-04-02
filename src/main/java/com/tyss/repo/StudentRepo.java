package com.tyss.repo;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.tyss.entity.Student;

public interface StudentRepo extends JpaRepository<Student, Integer> {
	
	Optional<Student> findByEmail(String email);

	List<Student> findByUserUid(Integer uid);

	Integer countByUserUid(Integer uid);

	@Query("SELECT s.name FROM Student s WHERE s.user.uid =?1 ORDER BY s.createdDate DESC LIMIT 4")
	List<String> getRecentStudents(Integer uid);
}
