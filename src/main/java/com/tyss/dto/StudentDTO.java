package com.tyss.dto;

import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StudentDTO {

    private String name;
    private String email;
    private List<Integer> courseIds;
}