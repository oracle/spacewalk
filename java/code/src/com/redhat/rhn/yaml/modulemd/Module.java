package com.redhat.rhn.yaml.modulemd;

import java.util.ArrayList;
import java.util.Objects;

/**
 * Module - Domain object used to model modulemd YAML documents found
 * in modules.yaml files.
 * This entity doesn't model the whole modulemd document, only those
 * fields necessary to uniquely identify a docuemnt and list the rpm
 * artifacts.
 */
public class Module {
    private String name;
    private String stream;
    private Long version;
    private String context;
    private String arch;
    private String summary;
    private String description;
    private ArrayList<String> rpms = new ArrayList<String>();

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param n the name to set
     */
    public void setName(String n) {
        this.name = n;
    }

    /**
     * @return the stream
     */
    public String getStream() {
        return stream;
    }

    /**
     * @param s the stream to set
     */
    public void setStream(String s) {
        this.stream = s;
    }

    /**
     * @return the version
     */
    public Long getVersion() {
        return version;
    }

    /**
     * @param v the version to set
     */
    public void setVersion(Long v) {
        this.version = v;
    }

    /**
     * @return the context
     */
    public String getContext() {
        return context;
    }

    /**
     * @param c the context to set
     */
    public void setContext(String c) {
        this.context = c;
    }

    /**
     * @return the arch
     */
    public String getArch() {
        return arch;
    }

    /**
     * @param a the arch to set
     */
    public void setArch(String a) {
        this.arch = a;
    }

    /**
     * @return the summary
     */
    public String getSummary() {
        return summary;
    }

    /**
     * @param s the summary to set
     */
    public void setSummary(String s) {
        this.summary = s;
    }

    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param d the description to set
     */
    public void setDescription(String d) {
        this.description = d;
    }

    /**
     * @return the rpms
     */
    public ArrayList<String> getRpms() {
        return rpms;
    }

    /**
     * @param r the rpms to set
     */
    public void setRpms(ArrayList<String> r) {
        this.rpms = r;
    }

    @Override
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }

        if (!(o instanceof Module)) {
            return false;
        }

        Module module = (Module) o;
        return Objects.equals(name, module.name) &&
            Objects.equals(stream, module.stream) &&
            Objects.equals(version, module.version) &&
            Objects.equals(context, module.context) &&
            Objects.equals(arch, module.arch);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, stream, version, context, arch);
    }
}
